"""Auth routes — signup, login, refresh, /me, password reset."""

from typing import Annotated

from fastapi import APIRouter, Depends, status
from fastapi.responses import Response

from iotd.api.cache import NO_STORE
from iotd.api.controllers.auth import AuthController
from iotd.api.controllers.password_reset import PasswordResetController
from iotd.api.schemas.auth import (
    LoginRequest,
    PasswordResetConfirm,
    PasswordResetRequest,
    RefreshRequest,
    SignupRequest,
    TokenPair,
    UserPublic,
)
from iotd.dependencies import get_auth_controller, get_current_user, get_password_reset_controller
from iotd.models.user import User

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post(
    "/signup",
    response_model=TokenPair,
    response_model_by_alias=True,
    status_code=status.HTTP_201_CREATED,
    summary="Create a new account and receive a token pair",
    dependencies=[NO_STORE],
)
async def signup(
    body: SignupRequest,
    controller: Annotated[AuthController, Depends(get_auth_controller)],
) -> TokenPair:
    return await controller.signup(body)


@router.post(
    "/login",
    response_model=TokenPair,
    response_model_by_alias=True,
    summary="Exchange email + password for a token pair",
    dependencies=[NO_STORE],
)
async def login(
    body: LoginRequest,
    controller: Annotated[AuthController, Depends(get_auth_controller)],
) -> TokenPair:
    return await controller.login(body)


@router.post(
    "/refresh",
    response_model=TokenPair,
    response_model_by_alias=True,
    summary="Exchange a refresh token for a fresh pair",
    dependencies=[NO_STORE],
)
async def refresh(
    body: RefreshRequest,
    controller: Annotated[AuthController, Depends(get_auth_controller)],
) -> TokenPair:
    return await controller.refresh(body.refresh_token)


@router.get(
    "/me",
    response_model=UserPublic,
    response_model_by_alias=True,
    summary="Return the authenticated user's profile",
    dependencies=[NO_STORE],
)
async def me(user: Annotated[User, Depends(get_current_user)]) -> UserPublic:
    return UserPublic.model_validate(user)


@router.post(
    "/password-reset/request",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Send a password-reset email if the address is registered",
    dependencies=[NO_STORE],
)
async def request_password_reset(
    body: PasswordResetRequest,
    controller: Annotated[PasswordResetController, Depends(get_password_reset_controller)],
) -> Response:
    await controller.request_reset(body)
    # Always 204 — never reveal whether the email is registered. Account
    # enumeration is a leak we don't need to enable just for nicer errors.
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post(
    "/password-reset/confirm",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Consume a password-reset token and set a new password",
    dependencies=[NO_STORE],
)
async def confirm_password_reset(
    body: PasswordResetConfirm,
    controller: Annotated[PasswordResetController, Depends(get_password_reset_controller)],
) -> Response:
    await controller.confirm_reset(body)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
