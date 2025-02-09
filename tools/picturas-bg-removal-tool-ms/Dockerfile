FROM python:3.12 AS builder

RUN apt-get update && apt-get install ffmpeg libsm6 libxext6  -y

RUN pip install poetry==1.8

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache

WORKDIR /app

COPY pyproject.toml poetry.lock ./

RUN --mount=type=cache,target=$POETRY_CACHE_DIR poetry install --without dev --no-root

FROM python:3.12-slim AS runtime

ENV VIRTUAL_ENV=/app/.venv \
    PATH="/app/.venv/bin:$PATH"

ENV PICTURAS_LOG_LEVEL=WARN

COPY --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}

COPY picturas_bg_removal_tool_ms ./picturas_bg_removal_tool_ms

ENTRYPOINT ["python", "-m", "picturas_bg_removal_tool_ms.main"]
