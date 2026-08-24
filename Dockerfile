FROM alpine:3.22

RUN apk add --no-cache bash git ripgrep libgcc libstdc++ tmux \
 && wget -O /etc/apk/keys/claude-code.rsa.pub https://downloads.claude.ai/keys/claude-code.rsa.pub \
 && echo "https://downloads.claude.ai/claude-code/apk/stable" >> /etc/apk/repositories \
 && apk update && apk add --no-cache claude-code

ENV USE_BUILTIN_RIPGREP=0
