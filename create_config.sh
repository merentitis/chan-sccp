#!/bin/sh
#
# create_config.sh
#
# Script to create config.h for compatibility with
# different asterisk versions.
#
# thanks to: Armin Schindler <armin@melware.de>
#

CONFIGFILE="config.h"

if [ -e "$CONFIGFILE" ]; then
	exit
fi

if [ $# -lt 1 ]; then
	echo >&2 "Missing argument"
	exit 1
fi

INCLUDEDIR="$1/asterisk"

if [ ! -d "$INCLUDEDIR" ]; then
	echo >&2 "Include directory '$INCLUDEDIR' does not exist"
	exit 1
fi

echo "Checking Asterisk version..."

echo "/*" >$CONFIGFILE
echo " * automatically generated by $0 `date`" >>$CONFIGFILE
echo " */" >>$CONFIGFILE
echo >>$CONFIGFILE
echo "#ifndef CHAN_SCCP_CONFIG_H" >>$CONFIGFILE
echo "#define CHAN_SCCP_CONFIG_H" >>$CONFIGFILE
echo >>$CONFIGFILE

echo -n "Build PARK functions (y/n)[n]?"
read key
if [ "$key" = "y" ]
then
	echo "#define CS_SCCP_PARK"  >>$CONFIGFILE
fi

echo -n "Build PICKUP functions (y/n)[n]?"
read key
if [ "$key" = "y" ]
then
        echo "#define CS_SCCP_PICKUP"  >>$CONFIGFILE
fi

echo -n "Use realtime functionality (y/n)[n]?"
read key
if [ "$key" = "y" ]
then
        echo "#define CS_SCCP_REALTIME"  >>$CONFIGFILE
fi


if grep -q "struct ast_channel_tech" $INCLUDEDIR/channel.h; then
	echo "#define CS_AST_HAS_TECH_PVT" >>$CONFIGFILE
	echo " * found 'struct ast_channel_tech'"
else
	echo "#undef CS_AST_HAS_TECH_PVT" >>$CONFIGFILE
	echo " * no 'struct ast_channel_tech', using old pvt"
fi

if grep -q "ast_bridged_channel" $INCLUDEDIR/channel.h; then
        echo "#define CS_AST_HAS_BRIDGED_CHANNEL" >>$CONFIGFILE
        echo " * found 'ast_bridged_channel'"
fi

if grep -q "struct ast_callerid" $INCLUDEDIR/channel.h; then
	echo "#define CS_AST_CHANNEL_HAS_CID" >>$CONFIGFILE
	echo " * found 'struct ast_callerid'"
else
	echo "#undef CS_AST_CHANNEL_HAS_CID" >>$CONFIGFILE
	echo " * no 'struct ast_callerid'"
fi

if grep -q "AST_MAX_CONTEXT" $INCLUDEDIR/channel.h; then
        echo " * found 'AST_MAX_CONTEXT'"
else
        echo "#define AST_MAX_CONTEXT AST_MAX_EXTENSION" >>$CONFIGFILE
        echo " * no 'AST_MAX_CONTEXT'"
fi

if grep -q "MAX_MUSICCLASS" $INCLUDEDIR/channel.h; then
        echo " * found 'MAX_MUSICCLASS'"
else
        echo "#define MAX_MUSICCLASS MAX_LANGUAGE" >>$CONFIGFILE
        echo " * no 'MAX_MUSICCLASS'"
fi

if grep -q "AST_MAX_ACCOUNT_CODE" $INCLUDEDIR/channel.h; then
        echo " * found 'AST_MAX_ACCOUNT_CODE'"
else
        echo "#define AST_MAX_ACCOUNT_CODE MAX_LANGUAGE" >>$CONFIGFILE
        echo " * no 'AST_MAX_ACCOUNT_CODE'"
fi

if grep -q "AST_CONTROL_HOLD" $INCLUDEDIR/frame.h; then
	echo "#define CS_AST_CONTROL_HOLD" >>$CONFIGFILE
	echo " * found 'AST_CONTROL_HOLD'"
else
	echo "#undef CS_AST_CONTROL_HOLD" >>$CONFIGFILE
	echo " * no 'AST_CONTROL_HOLD'"
fi

if grep -q "ast_config_load" $INCLUDEDIR/config.h; then
	echo " * found 'ast_config_load'"
else
	echo "#define ast_config_load(x) ast_load(x)" >>$CONFIGFILE
	echo "#define ast_config_destroy(x) ast_destroy(x)" >>$CONFIGFILE
	echo " * no 'ast_config_load'"
fi

if grep -rq "ast_copy_string" $INCLUDEDIR/; then
        echo "#define sccp_copy_string(x,y,z) ast_copy_string(x,y,z)" >>$CONFIGFILE
	echo " * found 'ast_copy_string'"
else
	echo "#define sccp_copy_string(x,y,z) strncpy(x,y,z - 1)" >>$CONFIGFILE
	echo " * no 'ast_copy_string'"
fi

if grep -q "AST_FLAG_MOH" $INCLUDEDIR/channel.h; then
	echo "#define CS_AST_HAS_FLAG_MOH" >>$CONFIGFILE
	echo " * found 'AST_FLAG_MOH'"
else
	echo "#define AST_FLAG_MOH              (1 << 6)" >>$CONFIGFILE
	echo " * no 'AST_FLAG_MOH'"
fi

if [ -e "$INCLUDEDIR/endian.h" ]; then
        echo "#define CS_AST_HAS_ENDIAN" >>$CONFIGFILE
        echo " * found endian.h"
fi

if [ -e "$INCLUDEDIR/strings.h" ]; then
        echo "#define CS_AST_HAS_STRINGS" >>$CONFIGFILE
        echo " * found strings.h"
fi

if grep -q "ast_app_has_voicemail.*folder" $INCLUDEDIR/app.h; then
        echo "#define CS_AST_HAS_NEW_VOICEMAIL" >>$CONFIGFILE
	echo " * found new ast_app_has_voicemail"
fi

if grep -q "ast_get_hint.*name" $INCLUDEDIR/pbx.h; then
        echo "#define CS_AST_HAS_NEW_HINT" >>$CONFIGFILE
        echo " * found new ast_get_hint"
fi

if [ -e "$INCLUDEDIR/devicestate.h" ]; then
        echo "#define CS_AST_HAS_NEW_DEVICESTATE" >>$CONFIGFILE
        echo " * found new devicestate.h"
	if grep -q "AST_DEVICE_RINGING" $INCLUDEDIR/devicestate.h; then
		echo "#define CS_AST_DEVICE_RINGING" >>$CONFIGFILE
		echo " * found AST_DEVICE_RINGING"
	fi
fi

if grep -q "ast_group_t" $INCLUDEDIR/channel.h; then
        echo "#define CS_AST_HAS_AST_GROUP_T" >>$CONFIGFILE
        echo " * found 'ast_group_t'"
fi

if grep -q "ast_app_separate_args" $INCLUDEDIR/app.h; then
        echo "#define CS_AST_HAS_APP_SEPARATE_ARGS" >>$CONFIGFILE
        echo "#define sccp_app_separate_args(x,y,z,w) ast_app_separate_args(x,y,z,w)" >>$CONFIGFILE
        echo " * found 'ast_app_separate_args'"
else
        echo " * no 'ast_app_separate_args'"
fi

if grep -q "AST_EXTENSION_RINGING" $INCLUDEDIR/pbx.h; then
        echo "#define CS_AST_HAS_EXTENSION_RINGING" >>$CONFIGFILE
        echo " * found AST_EXTENSION_RINGING"
fi

if grep -rq "ast_string_field_" $INCLUDEDIR/; then
        echo "#define CS_AST_HAS_AST_STRING_FIELD" >>$CONFIGFILE
        echo " * found ast_string_field_funcs"
fi

if grep -q "ast_cli_generator(const" $INCLUDEDIR/cli.h; then
	echo "#define CS_NEW_AST_CLI" >>$CONFIGFILE
	echo " * found new ast_cli_generator definition"
fi




echo "" >>$CONFIGFILE
echo "#endif /* CHAN_CAPI_CONFIG_H */" >>$CONFIGFILE
echo "" >>$CONFIGFILE

echo "config.h complete."
exit 0
