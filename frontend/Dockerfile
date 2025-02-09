FROM oven/bun:1

WORKDIR /app

COPY ./package.json .
COPY ./bun.lockb .

RUN bun install --frozen-lockfile

COPY ./ .

RUN bun run build

CMD ["bun", "run", "preview", "--host"]
