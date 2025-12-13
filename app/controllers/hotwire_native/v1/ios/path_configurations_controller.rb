# frozen_string_literal: true

class HotwireNative::V1::Ios::PathConfigurationsController < ApplicationController
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
        ios_system_image_name: "house"
      }
    ]

    return tabs unless user_signed_in?

    tabs + [
      {
        title: "Search",
        path: search_path,
        ios_system_image_name: "magnifyingglass"
      },
      {
        title: "Notifications",
        path: user_notifications_path,
        ios_system_image_name: "bell",
        show_notification_badge: true
      }
    ]
  end
end
