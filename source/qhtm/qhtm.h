/*----------------------------------------------------------------------

Copyright (c) 1998 Gipsysoft. All Rights Reserved.
Please see the file "licence.txt" for licencing details.

File:	QHTM.h
Owner:	russf@gipsysoft.com
Purpose:	GipsySoft HTML control

    For documentation see:
        -->http://www.gipsysoft.com/qhtm/doc/

----------------------------------------------------------------------*/
#ifndef QHTM_H
#define QHTM_H

#ifdef __cplusplus
#define QHTM_SENDMESSAGE ::SendMessage
#else
#define QHTM_SENDMESSAGE SendMessage
#endif //	__cplusplus
//
//	The window classname to be used when creating the QHTM controls.
//	Note that you can modify the styles for the control as any other control.
#define QHTM_CLASSNAME _T("QHTM_Window_Class_001")

//
//	Zoom constants, minimum, maximum and default.
#define QHTM_ZOOM_MIN 0
#define QHTM_ZOOM_MAX 4
#define QHTM_ZOOM_DEFAULT 2

//	Define a context type for printing. A context is used in a print procedure
//	to communicate with the app
typedef DWORD QHTMCONTEXT;

#ifdef __cplusplus

class CQHTMImageABC
//
//	Class used to allow the client to load and display images, including animations.
{
public:
  //
  //	Two drawing methods QHTM needs.
  virtual BOOL DrawFrame(UINT nFrame, HDC hdc, int left, int top) const = 0;
  virtual BOOL StretchFrame(UINT nFrame, HDC hdc, int left, int top, int right, int bottom) const = 0;

  //
  //	Return the number of frames in this image
  virtual UINT GetFrameCount() const = 0;

  //
  //	Return the the size, in pixels, of this image
  virtual const SIZE &GetSize() const = 0;

  //
  //	Return the time, in milliseconds, an individual frame remains on screen
  virtual int GetFrameTime(UINT nFrame) const = 0;

  //
  //	Destroy this image
  virtual void Destroy() = 0;
};

typedef CQHTMImageABC *(CALLBACK *funcQHTMImageCallback)(LPCTSTR pcszImageURL, LPARAM lParam);

//
//	Set the image callback for printing
BOOL WINAPI QHTM_PrintSetImageCallback(QHTMCONTEXT ctx, funcQHTMImageCallback pfunc);

#endif //	__cplusplus

#ifdef __cplusplus
extern "C"
{
#endif //	__cplusplus

  //
  //	What you get when the user clicks submit on a form
  typedef struct tagQHTMFORMSubmitField
  {
    LPCTSTR pcszName;
    LPCTSTR pcszValue;
  } QHTMFORMSubmitField, FAR *LPQHTMFORMSubmitField;

  typedef struct tagQHTMFORMSubmit
  {
    int cbSize;
    LPCTSTR pcszMethod;
    LPCTSTR pcszAction; //	URL
    LPCTSTR pcszName;
    UINT uFieldCount;

    LPQHTMFORMSubmitField parrFields;

  } QHTMFORMSubmit, FAR *LPQHTMFORMSubmit;

  //
  //	The usual notify with a return value.
  typedef struct tagNMQHTM
  {
    NMHDR hdr;
    LPCTSTR pcszLinkText;
    LRESULT resReturnValue;
    LPCTSTR pcszLinkID;
  } NMQHTM, FAR *LPNMQHTM;

  typedef struct tagQHTM_LINK_INFO
  {
    UINT cbSize; //	Size of the structure - must be set
    //
    //	You cannot modify these and you must take a copy of them if
    //	you wish to use them
    LPTSTR pszURL;
    LPTSTR pszID;
  } QHTM_LINK_INFO, FAR *LPQHTM_LINK_INFO;

  typedef HBITMAP(CALLBACK *funcQHTMBitmapCallback)(LPCTSTR pcszImageURL, LPARAM lParam);
  typedef HGLOBAL(CALLBACK *funcQHTMResourceCallback)(LPCTSTR pcszResourceName, LPARAM lParam);
  typedef void(CALLBACK *funcQHTMFORMCallback)(HWND hwndQHTM, LPQHTMFORMSubmit pFormSubmit, LPARAM lParam);

//
//	Sent whenever a link is clicked.
//	Set resReturnValue to FALSE to prevent QHTM from starting the user agent associated with the link.
//	This would be used if you had encoded some of your own links to internal functions in the HTML
//		see - APIExample of how this can be used.
#define QHTMN_HYPERLINK (1)

//
//	Load a HTML page from the resources
//	::SendMessage( hwnd, QHTM_LOAD_FROM_RESOURCE, (WPARAM)hInst, (LPARAM)name );
#define QHTM_LOAD_FROM_RESOURCE (WM_USER + 1)

//
//	Load the HTML from a file on disk.
//	::SendMessage( hwnd, QHTM_LOAD_FROM_FILE, 0, (LPARAM)pcszName );
#define QHTM_LOAD_FROM_FILE (WM_USER + 2)

//
//	Sets an option - see the values QHTM_OPT_* for further information
//	::SendMessage( hwnd, QHTM_SET_OPTION, (LPARAM)nOptionIndex, OptionValue );
#define QHTM_SET_OPTION (WM_USER + 3)

//
//	Gets an option - see the values QHTM_OPT_* for further information
//	OptionValue = ::SendMessage( hwnd, QHTM_GET_OPTION, (WPARAM)nOptionIndex, 0 );
#define QHTM_GET_OPTION (WM_USER + 4)

//
//	Goto a link with the HTML control. Used when you want to display a HTML document
//	not from the start but at a named section within the document.
//	::SendMessage( hwnd, QHTM_GOTO_LINK, 0, (LPARAM)pcszLinkName );
#define QHTM_GOTO_LINK (WM_USER + 5)

//
//	Get and set the scroll position of the control.
#define QHTM_GET_SCROLL_POS (WM_USER + 6)
#define QHTM_SET_SCROLL_POS (WM_USER + 7)

//
//	Get the title length from the HTML document
//	::SendMessage( hwnd, QHTM_GET_HTML_TITLE_LENGTH, 0, 0 );
//	returns the number of characters to store the title.
#define QHTM_GET_HTML_TITLE_LENGTH (WM_USER + 8)

//
//	Get the title from the HTML document
//	::SendMessage( hwnd, QHTM_GET_HTML_TITLE, nBufferLength, (LPARAM)pszBuffer );
//	returns the number of bytes copied, not including the terminating zero.
#define QHTM_GET_HTML_TITLE (WM_USER + 9)

//
//	Get the size of teh currently rendered HTML (size that would be needed not to scroll)
//	::SendMessage( hwnd, QHTM_GET_DRAWN_SIZE, 0, (LPARAM)&size );
//	returns TRUE if it succeeds
#define QHTM_GET_DRAWN_SIZE (WM_USER + 10)

//
//	Add some HTML to the current document
//	::SendMessage( hwnd, QHTM_ADD_HTML, 0, (LPARAM)"<b>Some</b> HTML added</br>");
//	No return value
#define QHTM_ADD_HTML (WM_USER + 11)

//
//	Find a link given a point structure
//	See QHTM_LINK_INFO structure for returned data. This structure is short lived and the
//	contents cannot be modified
//	::SendMessage( hwnd, QHTM_GET_LINK_FROM_POINT, (WPARAM)lppt, (LPARAM)lpLinkInfo);
//	Returns non-zero if there is a link at the point, zero otherwise
#define QHTM_GET_LINK_FROM_POINT (WM_USER + 12)

//
//	Submit a form.
//	::SendMessage( hwnd, QHTM_SUBMIT_FORM, 0, (LPARAM)(LPCTSTR)pcszFormName);
//	Returns non-zero if the form is submitted
#define QHTM_SUBMIT_FORM (WM_USER + 13)

//
//	Get the HRGN associated with a hyperlink
//	::SendMessage( hwnd, QHTM_GET_LINK_REGION, 0, (LPARAM)(LPCTSTR)pcszLinkID );
//	If the link exists then it return the HRGN of the link, otherwise it returns NULL
#define QHTM_GET_LINK_REGION (WM_USER + 14)

//
//	Get the LPARAM associated with this window. This is passed back in all callbacks
//	::SendMessage( hwnd, QHTM_SET_LPARAM, 0, lParam );
#define QHTM_SET_LPARAM (WM_USER + 15)

//
//	Set/get the HTML tooltips state.
//	::SendMessage( hwnd, QHTM_SET_OPTION, QHTM_OPT_TOOLTIPS, (LPARAM)bEnable );
#define QHTM_OPT_TOOLTIPS (1)
//	::SendMessage( hwnd, QHTM_SET_OPTION, QHTM_OPT_ZOOMLEVEL, (LPARAM)nLevel );
//	nLevel can be between QHTM_ZOOM_MIN and QHTM_ZOOM_MAX defined above
#define QHTM_OPT_ZOOMLEVEL (2)

//	::SendMessage( hwnd, QHTM_SET_OPTION, QHTM_OPT_MARGINS, (LPARAM)&rc );
//	Set the margins used by QHTM
#define QHTM_OPT_MARGINS (3)

//	::SendMessage( hwnd, QHTM_SET_OPTION, QHTM_OPT_USE_COLOR_STATIC, (LPARAM)bUse );
//	Force QHTM to sned a WM_CTLCOLORSTATIC to get the background brush
#define QHTM_OPT_USE_COLOR_STATIC (4)

//	::SendMessage( hwnd, QHTM_SET_OPTION, QHTM_OPT_ENABLE_SCROLLBARS, (LPARAM)bEnable );
//	Enable/disable scrollbars
#define QHTM_OPT_ENABLE_SCROLLBARS (5)

//	::SendMessage( hwnd, QHTM_SET_OPTION, QHTM_OPT_SET_IMAGE_CALLBACK, (LPARAM)MyImageCallback );
//	Set the function to call for image loading
#define QHTM_OPT_SET_IMAGE_CALLBACK (6)

//	::SendMessage( hwnd, QHTM_SET_OPTION, QHTM_OPT_SET_BITMAP_CALLBACK, (LPARAM)MyBitmapCallback );
//	Set the function to call for bitmap loading
#define QHTM_OPT_SET_BITMAP_CALLBACK (7)

//	::SendMessage( hwnd, QHTM_SET_OPTION, QHTM_OPT_SET_RESOURCE_CALLBACK, (LPARAM)MyResourceCallback );
//	Set the function to call for resource loading
#define QHTM_OPT_SET_RESOURCE_CALLBACK (8)

//	::SendMessage( hwnd, QHTM_SET_OPTION, QHTM_OPT_SET_FORM_SUBMIT_CALLBACK, (LPARAM)MyFormSubmitCallback );
//	Set the function to call for resource loading
#define QHTM_OPT_SET_FORM_SUBMIT_CALLBACK (9)

//	::SendMessage( hwnd, QHTM_SET_OPTION, QHTM_OPT_SET_ALWAYS_SHOW_TIPS, (LPARAM)bAlwaysShowTips );
//	Set whether tips are show even when the window is not the active one
#define QHTM_OPT_SET_ALWAYS_SHOW_TIPS (10)

//
//	Message cracker style macros
#define QHTM_LoadFromResourceName(hwnd, hinst, name)                                                                   \
  ((BOOL)QHTM_SENDMESSAGE((hwnd), QHTM_LOAD_FROM_RESOURCE, (WPARAM)(hinst), (LPARAM)(name)))
#define QHTM_LoadFromFile(hwnd, filename)                                                                              \
  ((BOOL)QHTM_SENDMESSAGE((hwnd), QHTM_LOAD_FROM_FILE, 0, (LPARAM)(LPCTSTR)(filename)))
#define QHTM_SetTooltips(hwnd, bEnable)                                                                                \
  ((void)QHTM_SENDMESSAGE(hwnd, QHTM_SET_OPTION, QHTM_OPT_TOOLTIPS, (LPARAM)bEnable))
#define QHTM_GetTooltips(hwnd) ((BOOL)QHTM_SENDMESSAGE(hwnd, QHTM_GET_OPTION, QHTM_OPT_TOOLTIPS, 0))
#define QHTM_SetZoomLevel(hwnd, nLevel)                                                                                \
  ((void)QHTM_SENDMESSAGE(hwnd, QHTM_SET_OPTION, QHTM_OPT_ZOOMLEVEL, (LPARAM)nLevel))
#define QHTM_GetZoomLevel(hwnd) ((int)QHTM_SENDMESSAGE(hwnd, QHTM_GET_OPTION, QHTM_OPT_ZOOMLEVEL, 0))
#define QHTM_GotoLink(hwnd, pcszLinkName) ((void)QHTM_SENDMESSAGE((hwnd), QHTM_GOTO_LINK, 0, (LPARAM)(pcszLinkName)))
#define QHTM_GetTitleLength(hwnd) ((UINT)QHTM_SENDMESSAGE((hwnd), QHTM_GET_HTML_TITLE_LENGTH, 0, 0))
#define QHTM_GetTitle(hwnd, pszBuffer, uBufferLength)                                                                  \
  ((UINT)QHTM_SENDMESSAGE((hwnd), QHTM_GET_HTML_TITLE, (WPARAM)(uBufferLength), (LPARAM)(pszBuffer)))
#define QHTM_GetScrollPos(hwnd) ((UINT)QHTM_SENDMESSAGE((hwnd), QHTM_GET_SCROLL_POS, 0, 0))
#define QHTM_SetScrollPos(hwnd, uScrollPos)                                                                            \
  ((UINT)QHTM_SENDMESSAGE((hwnd), QHTM_SET_SCROLL_POS, (WPARAM)(uScrollPos), 0))
#define QHTM_SetMargins(hwnd, rcMargins)                                                                               \
  ((void)QHTM_SENDMESSAGE(hwnd, QHTM_SET_OPTION, QHTM_OPT_MARGINS, (LPARAM) & rcMargins))
#define QHTM_GetMargins(hwnd, rcMargins)                                                                               \
  ((void)QHTM_SENDMESSAGE(hwnd, QHTM_GET_OPTION, QHTM_OPT_MARGINS, (LPARAM) & rcMargins))
#define QHTM_GetDrawnSize(hwnd, size) ((BOOL)QHTM_SENDMESSAGE(hwnd, QHTM_GET_DRAWN_SIZE, 0, (LPARAM)size))
#define QHTM_SetUseColorStatic(hwnd, bUse)                                                                             \
  ((void)QHTM_SENDMESSAGE(hwnd, QHTM_SET_OPTION, QHTM_OPT_USE_COLOR_STATIC, (LPARAM)bUse))
#define QHTM_GetUseColorStatic(hwnd) ((BOOL)QHTM_SENDMESSAGE(hwnd, QHTM_GET_OPTION, QHTM_OPT_USE_COLOR_STATIC, 0))
#define QHTM_EnableScrollbars(hwnd, bEnable)                                                                           \
  ((BOOL)QHTM_SENDMESSAGE(hwnd, QHTM_SET_OPTION, QHTM_OPT_ENABLE_SCROLLBARS, bEnable))
#define QHTM_AddHTML(hwnd, pcsz) ((BOOL)QHTM_SENDMESSAGE((hwnd), QHTM_ADD_HTML, 0, (LPARAM)(pcsz)))
#define QHTM_AddHTML2(hwnd, pcsz, bScrollToEnd)                                                                        \
  ((BOOL)QHTM_SENDMESSAGE((hwnd), QHTM_ADD_HTML, (WPARAM)bScrollToEnd, (LPARAM)(pcsz)))
#define QHTM_SetImageCallback(hwnd, pfuncImageCallback)                                                                \
  ((BOOL)QHTM_SENDMESSAGE(hwnd, QHTM_SET_OPTION, QHTM_OPT_SET_IMAGE_CALLBACK, (LPARAM)(pfuncImageCallback)))
#define QHTM_SetBitmapCallback(hwnd, pfuncBitmapCallback)                                                              \
  ((BOOL)QHTM_SENDMESSAGE(hwnd, QHTM_SET_OPTION, QHTM_OPT_SET_BITMAP_CALLBACK, (LPARAM)(pfuncBitmapCallback)))
#define QHTM_SetResourceCallback(hwnd, pfuncResourceCallback)                                                          \
  ((BOOL)QHTM_SENDMESSAGE(hwnd, QHTM_SET_OPTION, QHTM_OPT_SET_RESOURCE_CALLBACK, (LPARAM)(pfuncResourceCallback)))
#define QHTM_SetFormSubmitCallback(hwnd, pfuncCallback)                                                                \
  ((BOOL)QHTM_SENDMESSAGE(hwnd, QHTM_SET_OPTION, QHTM_OPT_SET_FORM_SUBMIT_CALLBACK, (LPARAM)(pfuncCallback)))
#define QHTM_SetAlwaysShowTips(hwnd, bShow)                                                                            \
  ((BOOL)QHTM_SENDMESSAGE(hwnd, QHTM_SET_OPTION, QHTM_OPT_SET_ALWAYS_SHOW_TIPS, (LPARAM)(bShow)))
#define QHTM_GetLinkInfo(hwnd, lppt, lpLinkInfo)                                                                       \
  ((BOOL)QHTM_SENDMESSAGE(hwnd, QHTM_GET_LINK_FROM_POINT, (WPARAM)(lppt), (LPARAM)(lpLinkInfo)))
#define QHTM_SubmitForm(hwnd, pcszFormName)                                                                            \
  ((BOOL)QHTM_SENDMESSAGE(hwnd, QHTM_SUBMIT_FORM, 0, (LPARAM)(LPCTSTR)(pcszFormName)))
#define QHTM_GetLinkRegion(hwnd, pcszLinkID)                                                                           \
  ((HRGN)QHTM_SENDMESSAGE(hwnd, QHTM_GET_LINK_REGION, 0, (LPARAM)(LPCTSTR)(pcszLinkID)))
#define QHTM_SetLPARAM(hwnd, lParam) ((void)QHTM_SENDMESSAGE(hwnd, QHTM_SET_LPARAM, 0, lParam))

  //
  //	Call this to initialise the Quick HTML control.
  BOOL WINAPI QHTM_Initialize(HINSTANCE hInst);

  //	Enable CoolTips in an application that currently uses the WIN32 Tool Tip control.
  BOOL WINAPI QHTM_EnableCooltips();

  //	Enable HTML to be rendered onto a button
  BOOL WINAPI QHTM_SetHTMLButton(HWND hwndButton);

#define QHTM_SOURCE_TEXT 1
#define QHTM_SOURCE_RESOURCE 2
#define QHTM_SOURCE_FILENAME 3

  //	Measure the height of some HTML given a width (registered only)
  BOOL WINAPI QHTM_GetHTMLHeight(HDC hdc, LPCTSTR pcsz, HINSTANCE hInst, UINT uSource, UINT uWidth, UINT *lpuHeight);

  //	Given a width render some HTML to a device context (registered only)
  BOOL WINAPI QHTM_RenderHTML(HDC hdc, LPCTSTR pcsz, HINSTANCE hInst, UINT uSource, UINT uWidth);

  //	Call this to create a new print context using a zoom level
  QHTMCONTEXT WINAPI QHTM_PrintCreateContext(UINT uZoomLevel);

  //	Call this to destroy a print context
  BOOL WINAPI QHTM_PrintDestroyContext(QHTMCONTEXT);

  //	Call this to set the HTML
  BOOL WINAPI QHTM_PrintSetText(QHTMCONTEXT ctx, LPCTSTR pcszText);

  //	Call this to set the HTML ftom a file
  BOOL WINAPI QHTM_PrintSetTextFile(QHTMCONTEXT ctx, LPCTSTR pcszFilename);

  //	Call this to set the HTML ftom a resource
  BOOL WINAPI QHTM_PrintSetTextResource(QHTMCONTEXT ctx, HINSTANCE hInst, LPCTSTR pcszName);

  //	Call this to layout the HTML. Returns the number of pages in nPages
  BOOL WINAPI QHTM_PrintLayout(QHTMCONTEXT ctx, HDC dc, LPCRECT pRect, LPINT nPages);

  //	Call to print a page of the HTML to a dc
  BOOL WINAPI QHTM_PrintPage(QHTMCONTEXT ctx, HDC hDC, UINT nPage, LPCRECT prDest);

  //	Using a zoom level
  int WINAPI QHTM_PrintGetHTMLHeight(HDC hDC, LPCTSTR pcszText, int nMaxWidth, UINT uZoomLevel);

  //	Set where QHTM gets it's resources for the hand cursor and the "no image" image. Maybe
  //	more later.
  void WINAPI QHTM_SetResources(HINSTANCE hInst, UINT uHandCursorID, UINT uNoImageBitmapID);

  //
  //	MessageBox() API replacement - use HTML for lpText, everything else is the same
  int WINAPI QHTM_MessageBox(HWND hwnd, LPCTSTR lpText, LPCTSTR lpCaption, UINT uType);

#ifdef __cplusplus
}
#endif //	__cplusplus

#ifdef __AFXWIN_H__

class CQhtmWnd : public CWnd
//
//	Simple wrapper class
{
public:
  //	Load the HTML from a file
  inline BOOL LoadFromFile(LPCTSTR pcszFilename)
  {
    return (BOOL)SendMessage(QHTM_LOAD_FROM_FILE, 0, (LPARAM)pcszFilename);
  }

  //	Load the HTML from a resource
  inline BOOL LoadFromResource(UINT uID)
  {
    return LoadFromResource(MAKEINTRESOURCE(uID));
  }

  //	Load the HTML from a resource
  inline BOOL LoadFromResource(LPCTSTR pcszName)
  {
    return (BOOL)SendMessage(QHTM_LOAD_FROM_RESOURCE, (WPARAM)AfxGetResourceHandle(), (LPARAM)pcszName);
  }

  //	Enable/disable tooltips on the control
  inline void SetToolTips(BOOL bEnable)
  {
    (void)SendMessage(QHTM_SET_OPTION, QHTM_OPT_TOOLTIPS, (WPARAM)bEnable);
  }

  //	Get the tooltips state
  inline BOOL GetToolTips()
  {
    return (BOOL)SendMessage(QHTM_GET_OPTION, QHTM_OPT_TOOLTIPS);
  }

  //	Enable/disable tooltips on the control
  inline void SetZoomLevel(int nLevel)
  {
    //	If this fires then either the window is invalid or teh zoom level is out of bounds!
    VERIFY(SendMessage(QHTM_SET_OPTION, QHTM_OPT_ZOOMLEVEL, (WPARAM)nLevel));
  }

  //	Get the current zoom level
  inline int GetZoomLevel()
  {
    return (int)SendMessage(QHTM_GET_OPTION, QHTM_OPT_ZOOMLEVEL);
  }

  //	Jump to a link
  inline void GotoLink(LPCTSTR pcszLink)
  {
    SendMessage(QHTM_GOTO_LINK, 0, (LPARAM)pcszLink);
  }

  void AddHTML(LPCTSTR pcszHTML, int nScroll)
  {
    QHTM_AddHTML2(GetSafeHwnd(), pcszHTML, nScroll);
  }

  HRGN GetLinkRegion(LPCTSTR pcszLinkID)
  {
    return (HRGN)QHTM_GetLinkRegion(GetSafeHwnd(), pcszLinkID);
  }
};

#endif //	__AFXWIN_H__

#endif // QHTM_H
