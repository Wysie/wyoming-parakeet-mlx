"""Event handler for clients of the Wyoming Parakeet MLX server."""
import argparse
import io
import logging
import tempfile
import time
import wave

import numpy as np
from wyoming.asr import Transcribe, Transcript
from wyoming.audio import AudioChunk, AudioChunkConverter, AudioStop
from wyoming.event import Event
from wyoming.info import Describe, Info
from wyoming.server import AsyncEventHandler

_LOGGER = logging.getLogger(__name__)


class ParakeetEventHandler(AsyncEventHandler):
    """Event handler for Wyoming protocol clients.

    Receives audio chunks, assembles them into a complete audio buffer,
    then transcribes using Parakeet MLX when audio stops.
    """

    def __init__(
        self,
        wyoming_info: Info,
        cli_args: argparse.Namespace,
        model,
        *args,
        **kwargs,
    ) -> None:
        super().__init__(*args, **kwargs)

        self.cli_args = cli_args
        self.wyoming_info_event = wyoming_info.event()
        self._model = model
        self.audio = bytes()
        self.audio_converter = AudioChunkConverter(
            rate=16000,
            width=2,
            channels=1,
        )

    async def handle_event(self, event: Event) -> bool:
        """Handle incoming Wyoming protocol events."""

        if AudioChunk.is_type(event.type):
            if not self.audio:
                _LOGGER.debug("Receiving audio")

            chunk = AudioChunk.from_event(event)
            chunk = self.audio_converter.convert(chunk)
            self.audio += chunk.audio

            return True

        if AudioStop.is_type(event.type):
            _LOGGER.debug(
                "Audio stopped. Received %d bytes (%.1f seconds)",
                len(self.audio),
                len(self.audio) / (16000 * 2),
            )

            text = ""
            try:
                text = await self._transcribe_audio()
            except Exception:
                _LOGGER.exception("Error during transcription")
            finally:
                # Always reset audio buffer
                self.audio = bytes()

            _LOGGER.info("Transcription: %s", text)

            await self.write_event(Transcript(text=text).event())
            _LOGGER.debug("Completed request")

            return False

        if Transcribe.is_type(event.type):
            _LOGGER.debug("Transcribe event received")
            return True

        if Describe.is_type(event.type):
            await self.write_event(self.wyoming_info_event)
            _LOGGER.debug("Sent info")
            return True

        return True

    async def _transcribe_audio(self) -> str:
        """Transcribe the accumulated audio buffer using Parakeet MLX.

        Parakeet MLX expects either a file path or a numpy array.
        We write the audio to a temporary WAV file and pass the path.
        """
        # Convert raw PCM bytes to a temporary WAV file
        with tempfile.NamedTemporaryFile(suffix=".wav", delete=True) as tmpfile:
            with wave.open(tmpfile, "wb") as wavfile:
                wavfile.setnchannels(1)
                wavfile.setsampwidth(2)  # 16-bit
                wavfile.setframerate(16000)
                wavfile.writeframes(self.audio)

            tmpfile.flush()

            start_time = time.monotonic()
            result = self._model.transcribe(tmpfile.name)
            end_time = time.monotonic()

            _LOGGER.debug(
                "Transcription took %.3f seconds", end_time - start_time
            )

            return result.text.strip()
