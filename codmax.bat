@echo off
:: Path to a file containing MINIMAX_API_KEY=your_key_here
:: Change this to wherever you store your MiniMax API key
set CREDENTIALS_FILE=%USERPROFILE%\.credentials\minimax.env

for /f "tokens=1,* delims==" %%A in ('findstr /i "MINIMAX_API_KEY" "%CREDENTIALS_FILE%"') do (
    if /i "%%A"=="MINIMAX_API_KEY" set "MINIMAX_API_KEY=%%B"
)
npx --yes @openai/codex@0.57.0 --profile m27 --config "model_providers.minimax.wire_api=chat" --config "model_providers.minimax.requires_openai_auth=false" %*
