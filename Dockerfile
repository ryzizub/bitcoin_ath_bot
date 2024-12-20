# Use the official Dart SDK image as base
FROM dart:stable AS build

# Set the working directory
WORKDIR /app

# Copy pubspec files and get dependencies
COPY pubspec.* ./
RUN dart pub get --no-precompile

# Copy the rest of the application
COPY . .

# Ensure dependencies are properly installed
RUN dart pub get --offline


# Compile the application
RUN dart compile exe lib/main.dart  \
    -o bitcoin_ath_bot

# # Create a smaller runtime image
FROM debian:stable-slim

# Install cron
RUN apt-get update && apt-get install -y cron \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the compiled executable
COPY --from=build /app/bitcoin_ath_bot ./

# Create a wrapper script that loads environment variables and runs the bot
RUN echo '#!/bin/sh\n\
# Load environment variables\n\
if [ -f /app/env.sh ]; then\n\
    . /app/env.sh\n\
fi\n\
/app/bitcoin_ath_bot >> /var/log/cron.log 2>&1' > /app/run-bot.sh \
    && chmod +x /app/run-bot.sh

# Create env.sh script (will be populated at runtime)
RUN touch /app/env.sh && chmod +x /app/env.sh

# Script to setup environment variables and start services
COPY <<-"EOF" /app/entrypoint.sh
#!/bin/sh
# Clear existing env.sh
echo "#!/bin/sh" > /app/env.sh

# Export all environment variables to env.sh
env | while read -r line; do
    echo "export $line" >> /app/env.sh
done

# Start cron and tail logs
cron && tail -f /var/log/cron.log
EOF

RUN chmod +x /app/entrypoint.sh

# Set up the cron job
RUN echo "*/1 * * * * /app/run-bot.sh" | crontab -

# Create the log file
RUN touch /var/log/cron.log

# Use the entrypoint script instead of direct cron command
CMD ["/app/entrypoint.sh"]
