"""Base classes for API request / response schemas.

The pipeline owns the canonical ORM ``BaseModel`` / ``BaseTable`` (with
``from_attributes`` + ``populate_by_name`` + ``extra="forbid"``), and we
re-export them so SQLModel tables inherit the same behaviour. Response
schemas additionally serialise field names as ``camelCase`` so the JSON
keys match what the React frontend already types — the snake-case Python
attribute name remains the canonical handle on the server side.
"""

from pipeline.schemas.shared import BaseModel as _PipelineBaseModel
from pipeline.schemas.shared import BaseTable
from pydantic import ConfigDict
from pydantic.alias_generators import to_camel

__all__ = ["BaseModel", "BaseTable", "RequestModel", "ResponseModel"]

BaseModel = _PipelineBaseModel


class ResponseModel(BaseModel):
    """Use as the base for any HTTP response body.

    Inherits ``from_attributes`` + ``populate_by_name`` + ``extra="forbid"``
    from the pipeline base, then overlays a ``to_camel`` alias generator so
    a Python attribute like ``verification_label`` is emitted as
    ``"verificationLabel"`` in JSON. ``populate_by_name=True`` means the
    server can still accept either casing on input.
    """

    model_config = ConfigDict(  # type: ignore[typeddict-unknown-key]
        from_attributes=True,
        populate_by_name=True,
        arbitrary_types_allowed=True,
        extra="forbid",
        alias_generator=to_camel,
        # Pydantic 2.11+ — applies when *we* call .model_dump(); FastAPI
        # routes still need response_model_by_alias=True for its own
        # serialise pass.
        serialize_by_alias=True,
    )


class RequestModel(BaseModel):
    """Use as the base for HTTP request bodies.

    Same camelCase / snake_case acceptance as ``ResponseModel``, but
    without ``serialize_by_alias`` since requests are only validated, never
    re-serialised back to the wire. Keeps the wire contract consistent —
    the FE sends ``{ "displayName": ... }`` for the same field that the
    response emits as ``displayName``.
    """

    model_config = ConfigDict(  # type: ignore[typeddict-unknown-key]
        from_attributes=True,
        populate_by_name=True,
        arbitrary_types_allowed=True,
        extra="forbid",
        alias_generator=to_camel,
    )
