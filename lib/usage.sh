function usage {
  echo "Usage: $(basename $0) -s example [options]"
  echo "Possible options are:"
  echo "    -s mysitename (mandatory, without first level domain)"
  echo "    -a '.com' (is your first level domain, default is defined in .vhostrc)"
  echo "    -d activate creation of a new DB"
  echo "    -i initialize creating .vhostrc file"
  echo "    -w bootstrap a wordless project inside my new vhost"
  echo "    -L specify a local for WordPress (defaults to it_IT)"
  echo "    -h display this help"

  exit 1
}

