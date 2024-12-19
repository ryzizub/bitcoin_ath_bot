# Use the official Dart SDK image as base
FROM dart:stable AS build

# Set the working directory
WORKDIR /app

# Copy pubspec files
COPY pubspec.* ./

# Get dependencies
RUN dart pub get

# Copy the rest of the application source code
COPY . .

# Compile the application
RUN dart compile exe lib/main.dart -o bin/bitcoin_ath_bot

# # Create a smaller runtime image
FROM debian:stable-slim

# Install cron
RUN apt-get update && apt-get install -y cron \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the compiled executable
COPY --from=build /app/bin/bitcoin_ath_bot ./

# Create a shell script to run the bot and log output
RUN echo '#!/bin/sh\n/app/bitcoin_ath_bot >> /var/log/cron.log 2>&1' > /app/run-bot.sh \
    && chmod +x /app/run-bot.sh

# Set up the cron job
RUN echo "*/15 * * * * /app/run-bot.sh" | crontab -

# Create the log file
RUN touch /var/log/cron.log

# Start cron and tail the logs
CMD cron && tail -f /var/log/cron.log
