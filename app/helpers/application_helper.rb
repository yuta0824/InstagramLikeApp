module ApplicationHelper
  def auth_locale_switch_path(locale, devise_resource_name)
    case controller_name
    when 'sessions'
      new_session_path(devise_resource_name, locale: locale)
    when 'registrations'
      new_registration_path(devise_resource_name, locale: locale)
    when 'passwords'
      new_password_path(devise_resource_name, locale: locale)
    else
      url_for(locale: locale)
    end
  end
end
