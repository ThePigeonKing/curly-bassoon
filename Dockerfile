# File to start FastApi backend app
FROM python:3.10

RUN pip3 install poetry --no-cache-dir
EXPOSE 8000
RUN mkdir /app
COPY pyproject.toml app/
WORKDIR /app/
RUN poetry install
COPY service /app/app/
RUN echo 'poetry run python3 -m app migrate && echo "Migrations run ok" || echo "Migrations failed"\npoetry run python3 -m app runserver 0.0.0.0:8000' > run.sh
ENTRYPOINT [ "/bin/sh" ]
CMD ["run.sh"]