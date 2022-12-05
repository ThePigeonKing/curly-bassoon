from logging import getLogger

from fastapi import FastAPI
from uvicorn import run

from service.config import DefaultSettings
from service.config.utils import get_settings
from service.handlers import list_of_routes
from service.utils.common import get_hostname


logger = getLogger(__name__)


def bind_routes(application: FastAPI, setting: DefaultSettings) -> None:
    """
    Bind all routes to application.
    """
    for route in list_of_routes:
        application.include_router(route, prefix=setting.PATH_PREFIX)


def get_app() -> FastAPI:
    """
    Creates application and all dependable objects.
    """
    description = "Микросервис, реализующий возможность укорачивать ссылки."

    tags_metadata = [
        {
            "name": "Url",
            "description": "Main service API",
        },
        {
            "name": "Health check",
            "description": "API health check.",
        },
    ]

    application = FastAPI(
        title="Curly bassoon",
        description=description,
        docs_url="/swagger",
        openapi_url="/openapi",
        version="1.0.0",
        openapi_tags=tags_metadata,
    )
    settings = get_settings()
    bind_routes(application, settings)
    application.state.settings = settings
    return application


app = get_app()


if __name__ == "__main__":  # pragma: no cover
    settings_for_application = get_settings()
    run(
        "service.__main__:app",
        host=get_hostname(settings_for_application.APP_HOST),
        port=settings_for_application.APP_PORT,
        reload=True,
        reload_dirs=["service", "tests"],
        log_level="debug",
    )
