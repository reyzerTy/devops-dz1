FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
ARG VERSION=dev
RUN echo "${VERSION}" > /app/VERSION
ENV APP_PORT=5002
ENV PYTHONDONTWRITEBYTECODE=1
ENV MARKER=devlab
EXPOSE 5002
CMD ["python", "app.py"]
