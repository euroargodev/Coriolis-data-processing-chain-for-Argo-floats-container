## Python Bindings

The Python app is located under: decArgo_soft/soft/decoder_api

To run the decoder with its associated bindings, run the following steps.

1. Copy `.env.demo` as `.env` file to configure the decoder for the demonstration.

2. Run decoder demo with matlab runtime thanks to docker compose

   ```bash
   ./docker-decoder-python-binding-linux.sh 6902892
   ```

3. Check next directory to see decoder outputs : `./decArgo_demo/output`
