ARG RELEASE_NAME=sim_web_dev

# Stage 0: Build the release
FROM erlang:28-alpine AS builder
ARG RELEASE_NAME
RUN apk add git
WORKDIR /erl.web.sim
# Copy the application source code
COPY . .
# clean up build folder with previous release
RUN rm -f -R _build/default/rel/$RELEASE_NAME
# Build the release (using rebar3 as an example)
RUN rebar3 do version
RUN rebar3 do clean --all
RUN rebar3 release -n $RELEASE_NAME

# Stage 1: Create the final, minimal image
FROM erlang:28-alpine
ARG RELEASE_NAME
RUN mkdir sim_web
WORKDIR /sim_web

# Copy the release from the builder stage
COPY --from=builder erl.web.sim/_build/default/rel/$RELEASE_NAME .

# Expose necessary ports 
EXPOSE 8000

# Command to run the Erlang application release
ENV RELEASE_NAME=$RELEASE_NAME
CMD bin/${RELEASE_NAME} console

# Command from host terminal to build image
#DEV  docker build --build-arg RELEASE_NAME=sim_web_dev -t sim_web_dev --file Dockerfile .
#PROD docker build --build-arg RELEASE_NAME=sim_web -t sim_web --file Dockerfile .

# docker run -it --rm erlang:slim erl
