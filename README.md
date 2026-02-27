# Wyoming Parakeet MLX

A Wyoming protocol server for the [Parakeet MLX](https://github.com/senstella/parakeet-mlx) speech-to-text system. This allows you to use Nvidia's high-performance Parakeet ASR models, running natively on Apple Silicon via MLX, as a speech-to-text provider for [Home Assistant](https://www.home-assistant.io/).

This project provides a simple, efficient bridge between Home Assistant's voice pipeline and the `parakeet-mlx` library, offering a significant speed and performance advantage over CPU-based or non-native solutions on Mac hardware.

It is designed as a drop-in replacement for `wyoming-mlx-whisper`, but uses the Parakeet model for faster, streaming-capable transcription (English-focused).

## Features

*   **High Performance:** Leverages Apple Silicon's GPU for fast inference via the MLX framework.
*   **Streaming Ready:** Built on Parakeet, which supports streaming transcription for lower perceived latency (though this implementation uses chunk-based transcription for simplicity).
*   **Easy Installation:** Simple setup with a single script to run as a background service on macOS.
*   **Home Assistant Integration:** Implements the Wyoming protocol for seamless integration with Home Assistant's voice pipelines.
*   **Lightweight:** Parakeet models are significantly smaller than Whisper, requiring less memory.

## Requirements

*   macOS with Apple Silicon (M1, M2, M3, M4, etc.)
*   Python 3.10+
*   [uv](https://docs.astral.sh/uv/) (for Python version management and package installation)
*   [ffmpeg](https://ffmpeg.org/) (for audio processing)

## Installation

1.  **Install Dependencies:**

    Open a terminal on your Mac and install `ffmpeg` and `uv` using Homebrew.

    ```bash
    brew install ffmpeg uv
    ```

2.  **Clone the Repository:**

    ```bash
    git clone https://github.com/Wysie/wyoming-parakeet-mlx.git
    cd wyoming-parakeet-mlx
    ```

3.  **Set Up the Environment:**

    Run the setup script to create a virtual environment with Python 3.12 and install all dependencies.

    ```bash
    ./script/setup
    ```

4.  **Install as a Service (optional):**

    To run the server in the background and automatically on login:

    ```bash
    ./install_service.sh
    ```

    The server will start automatically and listen on `tcp://0.0.0.0:10301`.

## Home Assistant Configuration

1.  Go to **Settings > Devices & Services > Add Integration**.
2.  Search for **Wyoming Protocol** and select it.
3.  Enter the IP address of your Mac and the port `10301`.
4.  Click **Submit**. The Parakeet STT service should now be available to use in your voice pipelines.

## Usage

The server is controlled via `launchctl`.

*   **To Stop the Service:**
    ```bash
    launchctl unload ~/Library/LaunchAgents/com.wyoming_parakeet_mlx.plist
    ```
*   **To Start the Service Manually:**
    ```bash
    launchctl load ~/Library/LaunchAgents/com.wyoming_parakeet_mlx.plist
    ```
*   **To View Logs:**
    Logs are stored in the `log` directory within the repository folder.
    ```bash
    tail -f log/run.out
    tail -f log/run.err
    ```

### Running Manually

To run the server directly in your terminal for debugging:

```bash
./wyoming-parakeet-mlx.sh --debug
```

Or with a custom port:

```bash
.venv/bin/python -m wyoming_parakeet_mlx --uri tcp://0.0.0.0:10301 --debug
```

## Uninstallation

Run the `uninstall_service.sh` script to stop and remove the `launchd` service.

```bash
./uninstall_service.sh
```

You can then safely delete the repository folder.

## License and Acknowledgements

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

This project is a derivative work and would not be possible without the excellent open-source projects it builds upon. We gratefully acknowledge their contributions.

*   **Core ASR Engine:** [parakeet-mlx](https://github.com/senstella/parakeet-mlx) by Senstella (Apache 2.0 License)
*   **Server Architecture:** The server structure and macOS service scripts are heavily based on [wyoming-mlx-whisper](https://github.com/vincent861223/wyoming-mlx-whisper) by Dr. Serge Victor (MIT License).
*   **Communication Protocol:** [wyoming](https://github.com/rhasspy/wyoming) by Michael Hansen (MIT License).
*   **ASR Model:** The Parakeet models are developed by [NVIDIA NeMo](https://github.com/NVIDIA/NeMo) (Apache 2.0 License).
*   **ML Framework:** The underlying MLX framework is developed by [Apple](https://github.com/ml-explore/mlx) (MIT License).

For full license details of all upstream dependencies, please see the [NOTICE](NOTICE) file.
