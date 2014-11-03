# NIS
# ===
#
# Installs the package nis and libpam-unix2.
# Starts the service nis with status test -f /var/run/ypbind.pid.
# Adds the file /etc/yp.conf with content nis/etc/yp.conf.
# Adds the file /etc/defaultdomain with content $network.
# Adds the file /etc/pam.d/common-auth with content nis/etc/pam.d/common-auth.
# Executes /bin/echo '+::::::' >>/etc/passwd.
# Executes /bin/echo '+:::' >>/etc/group.
# Executes /bin/echo '+::::::::' >>/etc/shadow.
#
# Parameters
# $network
# Name of the network.
#
#Limitations - only one or two extra auth parameters - cant do array iteration and index storing
class auth ( 
   $recipe = $auth::params::recipe, 
   $pam_system_auth  = $auth::params::pam_system_auth,
   $pam_password_auth  = $auth::params::pam_password_auth,
   $extraauth = $auth::params::extraauth,
   $extraauth2 = $auth::params::extraauth2,
   ) inherits auth::params {

   notify { "recipe is $recipe": } 
if $recipe == "ad" or $recipe == "ad_auth_pp_id"  {
   include sss

}

#if $recipe == "ad_auth_pp_id" or $recipe == "pp_nis" {
   include nis::client
#}



       if $extraauth2 == "none"  {
           $changeset=[
            "set *[. = 'passwd']/service[1] files",
            "set *[. = 'passwd']/service[2] $extraauth",
            "set *[. = 'group']/service[1] files",
            "set *[. = 'group']/service[2] $extraauth",
            "set *[. = 'shadow']/service[1] files",
            "set *[. = 'shadow']/service[2] $extraauth",
            "set *[. = 'automount']/service[1] files",
            "set *[. = 'automount']/service[2] nis",
             ]
      }
      else  {
          $changeset=[
            "set *[. = 'passwd']/service[1] files",
            "set *[. = 'passwd']/service[2] $extraauth",
            "set *[. = 'passwd']/service[3] $extraauth2",
            "set *[. = 'group']/service[1] files",
            "set *[. = 'group']/service[2] $extraauth",
            "set *[. = 'group']/service[3] $extraauth2",
            "set *[. = 'shadow']/service[1] files",
            "set *[. = 'shadow']/service[2] $extraauth",
            "set *[. = 'shadow']/service[3] $extraauth2",
            "set *[. = 'automount']/service[1] files",
            "set *[. = 'automount']/service[2] nis",
             ]


         }

    augeas{"nis":

       context   => '/files/etc/nsswitch.conf/',
       #This part changes options on an already existing line
       #This only works if the nsswitch.conf has passwd, group and shadow entries.  So you wont get the file created.
       changes   => $changeset,
     }
 if ! ($osfamily in ['RedHat']) {
    fail("access::access_wrapper does not support osfamily $osfamily")
  }
  else
  {

  #Not that secret, but can give a few things away
   file { '/etc/pam.d/system-auth':
         ensure =>present,
         source  => "$pam_system_auth",
         owner   => 'root',
         group   => 'root',
         mode    => '0444',
  }
   file { '/etc/pam.d/password-auth':
         ensure =>present,
         source  => "$pam_password_auth",
         owner   => 'root',
         group   => 'root',
         mode    => '0444',
  }
 }

}
