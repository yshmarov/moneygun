# frozen_string_literal: true

class HotwireNative::Android::PathConfigurationsController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    render json:
      {
        settings: {
          enable_feature_x: true,
          tabs: tabs
        },
        rules: [
          {
            patterns: [
              "/new$",
              "/edit$"
            ],
            properties: {
              context: "modal",
              pull_to_refresh_enabled: true
            }
          },
          {
            patterns: [
              "^/users/edit$"
            ],
            properties: {
              context: "default",
              pull_to_refresh_enabled: true
            }
          },
          {
            patterns: [
              "/numbers$"
            ],
            properties: {
              view_controller: "numbers"
            }
          },
          {
            patterns: [
              "/numbers/[0-9]+$"
            ],
            properties: {
              view_controller: "numbers_detail",
              context: "modal"
            }
          },
          {
            patterns: ["^/unauthorized"],
            properties: {
              view_controller: "unauthorized"
            }
          },
          {
            patterns: ["^/reset_app$"],
            properties: {
              view_controller: "reset_app"
            }
          },
          {
            patterns: [
              "^/$"
            ],
            properties: {
              presentation: "replace_root"
            }
          }
        ]
      }
  end

  private

  def tabs
    tabs = [
      {
        title: "Home",
        path: root_path,
        android_system_image_name: "home"
      }
    ]

    return tabs unless user_signed_in?

    tabs + [
      {
        title: "Search",
        path: search_path,
        android_system_image_name: "search"
      },
      {
        title: "Notifications",
        path: user_notifications_path,
        android_system_image_name: "notifications",
        show_notification_badge: true
      }
    ]
  end
end
