
#include "windows.ch"
#include "guilib.ch"

REQUEST HTIMER
REQUEST DBCREATE
REQUEST DBUSEAREA
REQUEST DBCREATEINDEX
REQUEST DBSEEK
REQUEST HWG_SHELLABOUT


Function Main

   LOCAL oForm := HFormTmpl():Read(example())

oForm:ShowMain()

RETURN NIL

#include "example.frm"
