FROM alpine:latest

RUN apk add --no-cache ttyd bash openssh-client

EXPOSE 7681

CMD ["ttyd", "-p", "7681", "bash"]
