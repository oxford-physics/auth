class auth::params (

          $recipe= hiera("auth::params::recipe", "pp_nis"),
          #files is always first
          #pass extraauth
          $extraauth = hiera("auth::params::extraauth",  "nis" ),
          $extraauth2 = hiera("auth::params::extraauth2",  "none" ),
          $pam_system_auth = hiera ("auth::params::pam_system_auth", "puppet:///modules/$module_name/pam_system_auth"),
          $pam_password_auth  = hiera("auth::params::pam_password_auth","puppet:///modules/$module_name/pam_password_auth"),

)
{}
