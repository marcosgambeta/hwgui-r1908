//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// C level painting functions
//
// Copyright 2005 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su

#include "guilib.h"
#include <hbapi.h>
#include <hbapiitm.h>
#include <hbvm.h>
#include <item.api>
#include <gtk/gtk.h>
#include "hwgtk.h"
#ifdef __XHARBOUR__
#include <hbfast.h>
#endif
// static HWGUI_PEN default_pen = { HWGUI_OBJECT_PEN,1,GDK_LINE_SOLID, };

void hwg_parse_color(HB_ULONG ncolor, GdkColor *pColor)
{
  char color[10] = {0};

  sprintf(color, "#%0*lX", 6, ncolor);
  color[8] = color[1];
  color[9] = color[2];
  color[1] = color[5];
  color[2] = color[6];
  color[5] = color[8];
  color[6] = color[9];
  color[7] = '\0';
  gdk_color_parse(color, pColor);
}

HB_FUNC(HWG_INVALIDATERECT)
{
  GtkWidget *widget = (GtkWidget *)HB_PARHANDLE(1);
  int x1, y1, x2, y2;

  if (hb_pcount() > 2)
  {
    x1 = hb_parni(3);
    y1 = hb_parni(4);
    x2 = hb_parni(5);
    y2 = hb_parni(6);
  }
  else
  {
    x1 = y1 = 0;
    x2 = widget->allocation.width;
    y2 = widget->allocation.height;
  }
  gtk_widget_queue_draw_area(widget, x1, y1, x2 - x1 + 1, y2 - y1 + 1);

  /*
     GdkRectangle rc;

     if( hb_pcount() > 2 )
     {
        rc.x = hb_parni(3);
        rc.y = hb_parni(4);
        rc.width = hb_parni(5) - rc.x + 1;
        rc.height = hb_parni(6) - rc.y + 1;
     }
     gdk_window_invalidate_rect( ((GtkWidget*)hb_parnl(1))->window,
        ( hb_pcount() > 2 )? &rc:HWG_NULLPTR, ( HB_ISNUM(2) )? hb_parni(2):1 );
  */
}

HB_FUNC(HWG_RECTANGLE)
{
  PHWGUI_HDC hDC = (PHWGUI_HDC)HB_PARHANDLE(1);
  int x1 = hb_parni(2), y1 = hb_parni(3);

  gdk_draw_rectangle(hDC->window, hDC->gc, 0, x1, y1, hb_parni(4) - x1 + 1, hb_parni(5) - y1 + 1);
}

HB_FUNC(HWG_DRAWLINE)
{
  PHWGUI_HDC hDC = (PHWGUI_HDC)HB_PARHANDLE(1);
  gdk_draw_line(hDC->window, hDC->gc, hb_parni(2), hb_parni(3), hb_parni(4), hb_parni(5));
}

HB_FUNC(HWG_PIE)
{
  /*
     int res = Pie(
      (HDC) hb_parnl(1),	// handle to device context
      hb_parni(2),	// x-coord. of bounding rectangle's upper-left corner
      hb_parni(3),	// y-coord. of bounding rectangle's upper-left corner
      hb_parni(4),	// x-coord. of bounding rectangle's lower-right corner
      hb_parni(5), 	// y-coord. bounding rectangle's f lower-right corner
      hb_parni(6),	// x-coord. of first radial's endpoint
      hb_parni(7),	// y-coord. of first radial's endpoint
      hb_parni(8),	// x-coord. of second radial's endpoint
      hb_parni(9) 	// y-coord. of second radial's endpoint
     );
     if( !res )
       hb_retnl( (HB_LONG) GetLastError() );
     else
     {
       hb_retnl( 0 );
     }
  */
}

HB_FUNC(HWG_ELLIPSE)
{
  PHWGUI_HDC hDC = (PHWGUI_HDC)HB_PARHANDLE(1);
  int x1 = hb_parni(2), y1 = hb_parni(3);

  gdk_draw_arc(hDC->window, hDC->gc, 0, x1, y1, hb_parni(4) - x1 + 1, hb_parni(5) - y1 + 1, 0, 360 * 64);
}

HB_FUNC(HWG_FILLRECT)
{
  int x1 = hb_parni(2), y1 = hb_parni(3);
  PHWGUI_HDC hDC = (PHWGUI_HDC)HB_PARHANDLE(1);
  PHWGUI_BRUSH brush = (PHWGUI_BRUSH)HB_PARHANDLE(6);

  GdkGCValues values;

  gdk_gc_get_values(hDC->gc, &values);
  gdk_gc_set_foreground(hDC->gc, &(brush->color));
  gdk_draw_rectangle(hDC->window, hDC->gc, 1, x1, y1, hb_parni(4) - x1 + 1, hb_parni(5) - y1 + 1);
  gdk_gc_set_foreground(hDC->gc, &(values.foreground));
}

HB_FUNC(HWG_ROUNDRECT)
{
  /*
     hb_parl( RoundRect(
      (HDC) hb_parnl( 1 ),   // handle of device context
      hb_parni( 2 ),         // x-coord. of bounding rectangle's upper-left corner
      hb_parni( 3 ),         // y-coord. of bounding rectangle's upper-left corner
      hb_parni( 4 ),         // x-coord. of bounding rectangle's lower-right corner
      hb_parni( 5 ),         // y-coord. of bounding rectangle's lower-right corner
      hb_parni( 6 ),         // width of ellipse used to draw rounded corners
      hb_parni( 7 )          // height of ellipse used to draw rounded corners
     ) );
  */
}

HB_FUNC(HWG_REDRAWWINDOW)
{
  GtkWidget *widget = (GtkWidget *)HB_PARHANDLE(1);
  /*
     GdkRectangle rc;

     if( hb_pcount() > 2 )
     {
        rc.x = 0;
        rc.y = 0;
        rc.width = widget->allocation.width;
        rc.height = widget->allocation.height;
     }
     gdk_window_invalidate_rect( widget->window, &rc, TRUE );
  */
  gtk_widget_queue_draw_area(widget, 0, 0, widget->allocation.width, widget->allocation.height);
}

HB_FUNC(HWG_DRAWBUTTON)
{
  PHWGUI_HDC hDC = (PHWGUI_HDC)HB_PARHANDLE(1);
  int left = hb_parni(2);
  int top = hb_parni(3);
  int right = hb_parni(4);
  int bottom = hb_parni(5);
  unsigned int iType = hb_parni(6);
  GtkStyle *style = hDC->widget->style;

  if (iType == 0)
  {
    // FillRect( hDC, &rc, (HBRUSH) (COLOR_3DFACE+1) );
    gdk_draw_rectangle(hDC->window, style->bg_gc[0], 1, left, top, right - left + 1, bottom - top + 1);
  }
  else
  {
    // FillRect( hDC, &rc, (HBRUSH) ( ( (iType & 2)? COLOR_3DSHADOW:COLOR_3DHILIGHT )+1) );
    gdk_draw_rectangle(hDC->window, (iType & 2) ? style->mid_gc[0] : style->light_gc[0], 1, left, top, right - left + 1,
                       bottom - top + 1);
    left++;
    top++;
    // FillRect( hDC, &rc, (HBRUSH) ( ( (iType & 2)? COLOR_3DHILIGHT:(iType & 4)? COLOR_3DDKSHADOW:COLOR_3DSHADOW )+1)
    // );
    gdk_draw_rectangle(hDC->window,
                       (iType & 2) ? style->light_gc[0] : ((iType & 4) ? style->dark_gc[0] : style->mid_gc[0]), 1, left,
                       top, right - left + 1, bottom - top + 1);
    right--;
    bottom--;
    right--;
    bottom--;
    if (iType & 4)
    {
      // FillRect( hDC, &rc, (HBRUSH) ( ( (iType & 2)? COLOR_3DSHADOW:COLOR_3DLIGHT )+1) );
      gdk_draw_rectangle(hDC->window, (iType & 2) ? style->mid_gc[0] : style->light_gc[0], 1, left, top,
                         right - left + 1, bottom - top + 1);
      left++;
      top++;
      // left ++; top ++;
      // FillRect( hDC, &rc, (HBRUSH) ( ( (iType & 2)? COLOR_3DLIGHT:COLOR_3DSHADOW )+1) );
      gdk_draw_rectangle(hDC->window, (iType & 2) ? style->light_gc[0] : style->mid_gc[0], 1, left, top,
                         right - left + 1, bottom - top + 1);
      right--;
      bottom--;
      // right --; bottom --;
    }
    // FillRect( hDC, &rc, (HBRUSH) (COLOR_3DFACE+1) );
    gdk_draw_rectangle(hDC->window, style->bg_gc[0], 1, left, top, right - left + 1, bottom - top + 1);
  }
}

/*
 * hwg_DrawEdge( hDC,x1,y1,x2,y2,nFlag,nBorder )
 */
HB_FUNC(HWG_DRAWEDGE)
{
  /*
     RECT rc;
     HDC hDC = (HDC) hb_parnl( 1 );
     UINT edge = (HB_ISNIL(6))? EDGE_RAISED : (UINT) hb_parni(6);
     UINT grfFlags = (HB_ISNIL(7))? BF_RECT : (UINT) hb_parni(7);

     rc.left = hb_parni( 2 );
     rc.top = hb_parni( 3 );
     rc.right = hb_parni( 4 );
     rc.bottom = hb_parni( 5 );

     hb_retl( DrawEdge( hDC, &rc, edge, grfFlags ) );
  */
}

HB_FUNC(HWG_LOADICON)
{
  /*
     if (HB_ISNUM(1))
     {
        hb_retnl( (HB_LONG) LoadIcon( HWG_NULLPTR, (LPCTSTR) hb_parnl( 1 ) ) );
     }
     else
     {
        hb_retnl( (HB_LONG) LoadIcon( GetModuleHandle( HWG_NULLPTR ), (LPCTSTR) hb_parc( 1 ) ) );
     }
  */
}

HB_FUNC(HWG_LOADIMAGE)
{
  /*
     hb_retnl( (HB_LONG)
            LoadImage( (HINSTANCE)hb_parnl(1),    // handle of the instance that contains the image
                    (LPCTSTR)hb_parc(2),          // name or identifier of image
                    (UINT) hb_parni(3),           // type of image
                    hb_parni(4),                  // desired width
                    hb_parni(5),                  // desired height
                    (UINT)hb_parni(6)             // load flags
     ) );
  */
}

HB_FUNC(HWG_LOADBITMAP)
{
  /*
     if (HB_ISNUM(1))
     {
       hb_retnl( (HB_LONG) LoadBitmap( HWG_NULLPTR, (LPCTSTR) hb_parnl( 1 ) ) );
     }
     else
     {
       hb_retnl( (HB_LONG) LoadBitmap( GetModuleHandle( HWG_NULLPTR ), (LPCTSTR) hb_parc( 1 ) ) );
     }
  */
}

/*
 * hwg_Window2Bitmap( hWnd )
 */
HB_FUNC(HWG_WINDOW2BITMAP)
{
}

/*
 * hwg_DrawBitmap( hDC, hBitmap, style, x, y, width, height )
 */
HB_FUNC(HWG_DRAWBITMAP)
{
  PHWGUI_HDC hDC = (PHWGUI_HDC)HB_PARHANDLE(1);
  PHWGUI_PIXBUF obj = (PHWGUI_PIXBUF)HB_PARHANDLE(2);
  gint x = hb_parni(4);
  gint y = hb_parni(5);
  gint width = hb_parni(6);
  gint height = hb_parni(7);

  gdk_draw_pixbuf(hDC->window, hDC->gc, obj->handle, 0, 0, x, y, width, height, GDK_RGB_DITHER_NONE, 0, 0);
}

/*
 * hwg_DrawTransparentBitmap( hDC, hBitmap, x, y )
 */
HB_FUNC(HWG_DRAWTRANSPARENTBITMAP)
{
}

/*  hwg_SpreadBitmap( hDC, hWnd, hBitmap, style )
 */
HB_FUNC(HWG_SPREADBITMAP)
{
}

HB_FUNC(HWG_GETBITMAPSIZE)
{
  PHWGUI_PIXBUF obj = (PHWGUI_PIXBUF)HB_PARHANDLE(1);
  PHB_ITEM aMetr = _itemArrayNew(2);
  PHB_ITEM temp;

  temp = _itemPutNL(HWG_NULLPTR, gdk_pixbuf_get_width(obj->handle));
  _itemArrayPut(aMetr, 1, temp);
  _itemRelease(temp);

  temp = _itemPutNL(HWG_NULLPTR, gdk_pixbuf_get_height(obj->handle));
  _itemArrayPut(aMetr, 2, temp);
  _itemRelease(temp);

  _itemReturn(aMetr);
  _itemRelease(aMetr);
}

HB_FUNC(HWG_OPENBITMAP)
{
  PHWGUI_PIXBUF hpix;
  GdkPixbuf *handle = gdk_pixbuf_new_from_file(hb_parc(1), HWG_NULLPTR);

  if (handle)
  {
    hpix = (PHWGUI_PIXBUF)hb_xgrab(sizeof(HWGUI_PIXBUF));
    hpix->type = HWGUI_OBJECT_PIXBUF;
    hpix->handle = handle;
    HB_RETHANDLE(hpix);
  }
}

HB_FUNC(HWG_OPENIMAGE)
{
  PHWGUI_PIXBUF hpix;
  GdkPixbuf *handle = gdk_pixbuf_new_from_file(hb_parc(1), HWG_NULLPTR);

  if (handle)
  {
    hpix = (PHWGUI_PIXBUF)hb_xgrab(sizeof(HWGUI_PIXBUF));
    hpix->type = HWGUI_OBJECT_PIXBUF;
    hpix->handle = handle;
    HB_RETHANDLE(hpix);
  }
}

GdkPixbuf *alpha2pixbuf(GdkPixbuf *hPixIn, long int nColor)
{
  short int r, g, b;

  r = nColor % 256;
  g = ((nColor - r) % 65536) / 256;
  b = (nColor - g - r) / 65536;
  return gdk_pixbuf_add_alpha(hPixIn, 1, (guchar)r, (guchar)g, (guchar)b);
}

/*
 * hwg_Alpha2Pixbuf( hBitmap, nColor )
 */
HB_FUNC(HWG_ALPHA2PIXBUF)
{
  PHWGUI_PIXBUF obj = (PHWGUI_PIXBUF)HB_PARHANDLE(1);
  GdkPixbuf *handle;

  if (obj && obj->handle)
  {
    handle = alpha2pixbuf(obj->handle, hb_parnl(2));
    gdk_pixbuf_unref(obj->handle);
    obj->handle = handle;
  }
}

HB_FUNC(HWG_DRAWICON)
{
  // DrawIcon( (HDC)hb_parnl( 1 ), hb_parni( 3 ), hb_parni( 4 ), (HICON)hb_parnl( 2 ) );
}

HB_FUNC(HWG_GETSYSCOLOR)
{
  hb_retnl(0); // (HB_LONG) GetSysColor( hb_parni( 1 ) ) );
}

#define PS_SOLID 0

HB_FUNC(HWG_CREATEPEN)
{
  PHWGUI_PEN hpen = (PHWGUI_PEN)hb_xgrab(sizeof(HWGUI_PEN));
  HB_ULONG ncolor = (HB_ULONG)hb_parnl(3);

  hpen->type = HWGUI_OBJECT_PEN;
  hpen->style = (hb_parni(1) == PS_SOLID) ? GDK_LINE_SOLID : GDK_LINE_ON_OFF_DASH;
  hpen->width = hb_parni(2);
  hwg_parse_color(ncolor, &(hpen->color));
  gdk_colormap_alloc_color(gdk_colormap_get_system(), &(hpen->color), FALSE, TRUE);

  HB_RETHANDLE(hpen);
}

HB_FUNC(HWG_CREATESOLIDBRUSH)
{
  PHWGUI_BRUSH hbrush = (PHWGUI_BRUSH)hb_xgrab(sizeof(HWGUI_BRUSH));
  HB_ULONG ncolor = (HB_ULONG)hb_parnl(1);

  hbrush->type = HWGUI_OBJECT_BRUSH;

  hwg_parse_color(ncolor, &(hbrush->color));
  gdk_colormap_alloc_color(gdk_colormap_get_system(), &(hbrush->color), FALSE, TRUE);

  HB_RETHANDLE(hbrush);
}

HB_FUNC(HWG_SELECTOBJECT)
{
  HWGUI_HDC_OBJECT *obj = (HWGUI_HDC_OBJECT *)HB_PARHANDLE(2);

  if (obj)
  {
    PHWGUI_HDC hDC = (PHWGUI_HDC)HB_PARHANDLE(1);
    GdkGCValues values;

    if (obj->type == HWGUI_OBJECT_PEN)
    {
      gdk_gc_set_foreground(hDC->gc, &(((PHWGUI_PEN)obj)->color));
      gdk_gc_get_values(hDC->gc, &values);
      gdk_gc_set_line_attributes(hDC->gc, ((PHWGUI_PEN)obj)->width, ((PHWGUI_PEN)obj)->style, values.cap_style,
                                 values.join_style);
    }
    else if (obj->type == HWGUI_OBJECT_BRUSH)
    {
      gdk_gc_set_background(hDC->gc, &(((PHWGUI_BRUSH)obj)->color));
    }
    else if (obj->type == HWGUI_OBJECT_FONT)
    {
      hDC->hFont = ((PHWGUI_FONT)obj)->hFont;
      pango_layout_set_font_description(hDC->layout, hDC->hFont);
    }
  }
  HB_RETHANDLE(HWG_NULLPTR);
}

HB_FUNC(HWG_DELETEOBJECT)
{
  HWGUI_HDC_OBJECT *obj = (HWGUI_HDC_OBJECT *)HB_PARHANDLE(1);

  if (obj->type == HWGUI_OBJECT_PEN)
  {
    hb_xfree(obj);
  }
  else if (obj->type == HWGUI_OBJECT_BRUSH)
  {
    hb_xfree(obj);
  }
  else if (obj->type == HWGUI_OBJECT_FONT)
  {
    pango_font_description_free(((PHWGUI_FONT)obj)->hFont);
    hb_xfree(obj);
  }
  else if (obj->type == HWGUI_OBJECT_PIXBUF)
  {
    gdk_pixbuf_unref(((PHWGUI_PIXBUF)obj)->handle);
    hb_xfree(obj);
  }
}

HB_FUNC(HWG_DEFINEPAINTSTRU)
{
  PHWGUI_PPS pps = (PHWGUI_PPS)hb_xgrab(sizeof(HWGUI_PPS));

  pps->hDC = HWG_NULLPTR;
  HB_RETHANDLE(pps);
}

HB_FUNC(HWG_BEGINPAINT)
{
  GtkWidget *widget = (GtkWidget *)HB_PARHANDLE(1);
  PHWGUI_PPS pps = (PHWGUI_PPS)HB_PARHANDLE(2);
  PHWGUI_HDC hDC = (PHWGUI_HDC)hb_xgrab(sizeof(HWGUI_HDC));

  memset(hDC, 0, sizeof(HWGUI_HDC));
  hDC->widget = widget;
  hDC->window = widget->window;
  hDC->gc = gdk_gc_new(widget->window);
  hDC->layout = gtk_widget_create_pango_layout(hDC->widget, HWG_NULLPTR);
  hDC->fcolor = hDC->bcolor = -1;

  pps->hDC = hDC;

  HB_RETHANDLE(hDC);
}

HB_FUNC(HWG_ENDPAINT)
{
  PHWGUI_PPS pps = (PHWGUI_PPS)HB_PARHANDLE(2);
  PHWGUI_HDC hDC = pps->hDC;

  if (hDC->layout)
  {
    g_object_unref((GObject *)hDC->layout);
  }
  g_object_unref((GObject *)hDC->gc);
  hb_xfree(hDC);
  hb_xfree(pps);
}

HB_FUNC(HWG_GETDC)
{
  PHWGUI_HDC hDC = (PHWGUI_HDC)hb_xgrab(sizeof(HWGUI_HDC));
  GtkWidget *widget = (GtkWidget *)HB_PARHANDLE(1);

  memset(hDC, 0, sizeof(HWGUI_HDC));
  hDC->widget = widget;
  hDC->window = widget->window;
  hDC->gc = gdk_gc_new(widget->window);
  hDC->layout = gtk_widget_create_pango_layout(hDC->widget, HWG_NULLPTR);
  hDC->fcolor = hDC->bcolor = -1;

  HB_RETHANDLE(hDC);
}

HB_FUNC(HWG_RELEASEDC)
{
  PHWGUI_HDC hDC = (PHWGUI_HDC)HB_PARHANDLE(2);

  if (hDC->layout)
  {
    g_object_unref((GObject *)hDC->layout);
  }
  g_object_unref((GObject *)hDC->gc);
  hb_xfree(hDC);
}

HB_FUNC(HWG_GETDRAWITEMINFO)
{
  /*
     DRAWITEMSTRUCT * lpdis = (DRAWITEMSTRUCT*)hb_parnl(1);
     PHB_ITEM aMetr = _itemArrayNew( 7 );
     PHB_ITEM temp;

     temp = _itemPutNL( HWG_NULLPTR, lpdis->itemID );
     _itemArrayPut( aMetr, 1, temp );
     _itemRelease( temp );

     temp = _itemPutNL( HWG_NULLPTR, lpdis->itemAction );
     _itemArrayPut( aMetr, 2, temp );
     _itemRelease( temp );

     temp = _itemPutNL( HWG_NULLPTR, (HB_LONG)lpdis->hDC );
     _itemArrayPut( aMetr, 3, temp );
     _itemRelease( temp );

     temp = _itemPutNL( HWG_NULLPTR, lpdis->rcItem.left );
     _itemArrayPut( aMetr, 4, temp );
     _itemRelease( temp );

     temp = _itemPutNL( HWG_NULLPTR, lpdis->rcItem.top );
     _itemArrayPut( aMetr, 5, temp );
     _itemRelease( temp );

     temp = _itemPutNL( HWG_NULLPTR, lpdis->rcItem.right );
     _itemArrayPut( aMetr, 6, temp );
     _itemRelease( temp );

     temp = _itemPutNL( HWG_NULLPTR, lpdis->rcItem.bottom );
     _itemArrayPut( aMetr, 7, temp );
     _itemRelease( temp );

     _itemReturn( aMetr );
     _itemRelease( aMetr );
  */
}

/*
 * hwg_DrawGrayBitmap( hDC, hBitmap, x, y )
 */
HB_FUNC(HWG_DRAWGRAYBITMAP)
{
}

HB_FUNC(HWG_GETCLIENTRECT)
{
  GtkWidget *widget = (GtkWidget *)HB_PARHANDLE(1);
  PHB_ITEM aMetr = hb_itemArrayNew(4);

  hb_itemPutNL(hb_arrayGetItemPtr(aMetr, 1), 0);
  hb_itemPutNL(hb_arrayGetItemPtr(aMetr, 2), 0);
  hb_itemPutNL(hb_arrayGetItemPtr(aMetr, 3), widget->allocation.width);
  hb_itemPutNL(hb_arrayGetItemPtr(aMetr, 4), widget->allocation.height);
  hb_itemRelease(hb_itemReturn(aMetr));
}

HB_FUNC(HWG_GETWINDOWRECT)
{
  /*
     RECT rc;
     PHB_ITEM aMetr = _itemArrayNew( 4 );
     PHB_ITEM temp;

     GetWindowRect( (HWND) hb_parnl( 1 ),	&rc );

     temp = _itemPutNL( HWG_NULLPTR, rc.left );
     _itemArrayPut( aMetr, 1, temp );
     _itemRelease( temp );

     temp = _itemPutNL( HWG_NULLPTR, rc.top );
     _itemArrayPut( aMetr, 2, temp );
     _itemRelease( temp );

     temp = _itemPutNL( HWG_NULLPTR, rc.right );
     _itemArrayPut( aMetr, 3, temp );
     _itemRelease( temp );

     temp = _itemPutNL( HWG_NULLPTR, rc.bottom );
     _itemArrayPut( aMetr, 4, temp );
     _itemRelease( temp );

     _itemReturn( aMetr );
     _itemRelease( aMetr );
  */
}

#ifdef HWGUI_FUNC_TRANSLATE_ON
HB_FUNC_TRANSLATE(INVALIDATERECT, HWG_INVALIDATERECT);
HB_FUNC_TRANSLATE(RECTANGLE, HWG_RECTANGLE);
HB_FUNC_TRANSLATE(DRAWLINE, HWG_DRAWLINE);
HB_FUNC_TRANSLATE(PIE, HWG_PIE);
HB_FUNC_TRANSLATE(ELLIPSE, HWG_ELLIPSE);
HB_FUNC_TRANSLATE(FILLRECT, HWG_FILLRECT);
HB_FUNC_TRANSLATE(ROUNDRECT, HWG_ROUNDRECT);
HB_FUNC_TRANSLATE(REDRAWWINDOW, HWG_REDRAWWINDOW);
HB_FUNC_TRANSLATE(DRAWBUTTON, HWG_DRAWBUTTON);
HB_FUNC_TRANSLATE(DRAWEDGE, HWG_DRAWEDGE);
HB_FUNC_TRANSLATE(LOADICON, HWG_LOADICON);
HB_FUNC_TRANSLATE(LOADIMAGE, HWG_LOADIMAGE);
HB_FUNC_TRANSLATE(LOADBITMAP, HWG_LOADBITMAP);
HB_FUNC_TRANSLATE(WINDOW2BITMAP, HWG_WINDOW2BITMAP);
HB_FUNC_TRANSLATE(DRAWBITMAP, HWG_DRAWBITMAP);
HB_FUNC_TRANSLATE(DRAWTRANSPARENTBITMAP, HWG_DRAWTRANSPARENTBITMAP);
HB_FUNC_TRANSLATE(SPREADBITMAP, HWG_SPREADBITMAP);
HB_FUNC_TRANSLATE(GETBITMAPSIZE, HWG_GETBITMAPSIZE);
HB_FUNC_TRANSLATE(OPENBITMAP, HWG_OPENBITMAP);
HB_FUNC_TRANSLATE(OPENIMAGE, HWG_OPENIMAGE);
HB_FUNC_TRANSLATE(DRAWICON, HWG_DRAWICON);
HB_FUNC_TRANSLATE(GETSYSCOLOR, HWG_GETSYSCOLOR);
HB_FUNC_TRANSLATE(CREATEPEN, HWG_CREATEPEN);
HB_FUNC_TRANSLATE(CREATESOLIDBRUSH, HWG_CREATESOLIDBRUSH);
HB_FUNC_TRANSLATE(SELECTOBJECT, HWG_SELECTOBJECT);
HB_FUNC_TRANSLATE(DELETEOBJECT, HWG_DELETEOBJECT);
HB_FUNC_TRANSLATE(DEFINEPAINTSTRU, HWG_DEFINEPAINTSTRU);
HB_FUNC_TRANSLATE(BEGINPAINT, HWG_BEGINPAINT);
HB_FUNC_TRANSLATE(ENDPAINT, HWG_ENDPAINT);
HB_FUNC_TRANSLATE(GETDC, HWG_GETDC);
HB_FUNC_TRANSLATE(RELEASEDC, HWG_RELEASEDC);
HB_FUNC_TRANSLATE(GETDRAWITEMINFO, HWG_GETDRAWITEMINFO);
HB_FUNC_TRANSLATE(DRAWGRAYBITMAP, HWG_DRAWGRAYBITMAP);
HB_FUNC_TRANSLATE(GETCLIENTRECT, HWG_GETCLIENTRECT);
HB_FUNC_TRANSLATE(GETWINDOWRECT, HWG_GETWINDOWRECT);
#endif
