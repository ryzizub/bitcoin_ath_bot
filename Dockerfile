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

ARG NOSTR
ARG BLUESKY_IDENTIFIER
ARG BLUESKY_PASSWORD
ARG MASTODON_BEARER_TOKEN

# Then use ENV to make them available at runtime
ENV NOSTR=$NOSTR
ENV BLUESKY_IDENTIFIER=$BLUESKY_IDENTIFIER
ENV BLUESKY_PASSWORD=$BLUESKY_PASSWORD
ENV MASTODON_BEARER_TOKEN=$MASTODON_BEARER_TOKEN

# Compile the application
RUN dart compile exe lib/main.dart  \
    --define=NOSTR="${NOSTR}" \
    --define=BLUESKY_IDENTIFIER="${BLUESKY_IDENTIFIER}" \
    --define=BLUESKY_PASSWORD="${BLUESKY_PASSWORD}" \
    --define=MASTODON_BEARER_TOKEN="${MASTODON_BEARER_TOKEN}" \
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

# Create a shell script to run the bot and log output
RUN echo '#!/bin/sh\n/app/bitcoin_ath_bot >> /var/log/cron.log 2>&1' > /app/run-bot.sh \
    && chmod +x /app/run-bot.sh

# Set up the cron job
RUN echo "*/1 * * * * /app/run-bot.sh" | crontab -

# Create the log file
RUN touch /var/log/cron.log

# Start cron and tail the logs
CMD cron && tail -f /var/log/cron.log
