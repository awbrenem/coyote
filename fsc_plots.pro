; docformat = 'rst'
;
; NAME:
;   FSC_PlotS
;
; PURPOSE:
;   The purpose of FSC_PlotS is to create a wrapper for the traditional IDL graphics
;   command, PlotS. The primary purpose of this is to create plot commands that work
;   and look identically both on the display and in PostScript files.
;
;******************************************************************************************;
;                                                                                          ;
;  Copyright (c) 2010, by Fanning Software Consulting, Inc. All rights reserved.           ;
;                                                                                          ;
;  Redistribution and use in source and binary forms, with or without                      ;
;  modification, are permitted provided that the following conditions are met:             ;
;                                                                                          ;
;      * Redistributions of source code must retain the above copyright                    ;
;        notice, this list of conditions and the following disclaimer.                     ;
;      * Redistributions in binary form must reproduce the above copyright                 ;
;        notice, this list of conditions and the following disclaimer in the               ;
;        documentation and/or other materials provided with the distribution.              ;
;      * Neither the name of Fanning Software Consulting, Inc. nor the names of its        ;
;        contributors may be used to endorse or promote products derived from this         ;
;        software without specific prior written permission.                               ;
;                                                                                          ;
;  THIS SOFTWARE IS PROVIDED BY FANNING SOFTWARE CONSULTING, INC. ''AS IS'' AND ANY        ;
;  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES    ;
;  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT     ;
;  SHALL FANNING SOFTWARE CONSULTING, INC. BE LIABLE FOR ANY DIRECT, INDIRECT,             ;
;  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED    ;
;  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;         ;
;  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND             ;
;  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT              ;
;  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS           ;
;  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                            ;
;******************************************************************************************;
;
;+
; :Description:
;   The purpose of FSC_PlotS is to create a wrapper for the traditional IDL graphics
;   command, PlotS. The primary purpose of this is to create plot commands that work
;   and look identically both on the display and in PostScript files.
;
; :Categories:
;    Graphics
;    
; :Params:
;    X: in, required, type=any
;         A vector or scalar argument providing the X components of the points to be
;         drawn or connected. May be a 2xN or 3xN array, if Y and Z parameters are
;         not used.
;    Y: in, optional, type=any
;         A vector or scalar argument providing the Y components of the points to be
;         drawn or connected.
;    Z: in, optional, type=any
;         A vector or scalar argument providing the Z components of the points to be
;         drawn or connected.
;         
; :Keywords:
;     color: in, optional, type=string/integer, default='black'
;        If this keyword is a string, the name of the data color. By default, 'black'.
;        Color names are those used with FSC_Color. Otherwise, the keyword is assumed 
;        to be a color index into the current color table. May be a vector of the same
;        length as X.
;     psym: in, optional, type=integer
;        Any normal IDL PSYM values, plus any value supported by the Coyote Library
;        routine SYMCAT. An integer between 0 and 46. 
;     symcolor: in, optional, type=string/integer/vector, default=COLOR
;        If this keyword is a string, the name of the symbol color. By default, same as COLOR.
;        Otherwise, the keyword is assumed to be a color index into the current color table.
;        May be a vector of the same length as X.
;     symsize: in, optional, type=float/vector, default=1.0
;        A scalar or vector of symbol sizes. Default is 1.0. May be a vector of the same 
;        length as X.
;     _extra: in, optional, type=any
;        Any keywords supported by the PLOTS command are allowed.
;         
; :Examples:
;    Use like the IDL PLOTS command::
;       IDL> FSC_Plot, Findgen(11)
;       IDL> FSC_PlotS, !X.CRange, [5,5], LINESTYLE=2, THICK=2, COLOR='red'
;       
; :Author:
;       FANNING SOFTWARE CONSULTING::
;           David W. Fanning 
;           1645 Sheely Drive
;           Fort Collins, CO 80526 USA
;           Phone: 970-221-0438
;           E-mail: davidf@dfanning.com
;           Coyote's Guide to IDL Programming: http://www.dfanning.com
;
; :History:
;     Change History::
;        Written, 12 November 2010. DWF.
;        Added SYMCOLOR keyword. PSYM accepts all values from SYMCAT. SYMCOLOR and SYMSIZE
;           keywords can be vectors the size of x. 15 November 2010. DWF
;        Added ability to support COLOR keyword as a vector the size of x. 15 November 2010. DWF
;
; :Copyright:
;     Copyright (c) 2010, Fanning Software Consulting, Inc.
;-
PRO FSC_PlotS, x, y, z, $
    COLOR=color, $
    PSYM=psym, $
    SYMCOLOR=symcolor, $
    SYMSIZE=symsize, $
    _EXTRA=extra

    Compile_Opt idl2

    ; Error handling.
    Catch, theError
    IF theError NE 0 THEN BEGIN
        Catch, /CANCEL
        void = Error_Message()
        RETURN
    ENDIF
    
    ; Need some help?
    IF N_Params() EQ 0 THEN BEGIN
        Print, 'USE SYNTAX: FSC_PlotS, x, y, [z]'
        RETURN
    ENDIF
    
   ; Check parameters and keywords.
   IF N_Elements(color) EQ 0 THEN color = 'black'
   IF N_Elements(psym) EQ 0 THEN psym = 0
   IF N_Elements(symcolor) EQ 0 THEN symcolor = 'black'
   IF N_Elements(symsize) EQ 0 THEN symsize = 1.0
   
   ; Be sure the vectors are the right length.
   CASE N_Params() OF
        1: xsize = N_Elements(x[0,*])
        ELSE: xsize = N_Elements(x)
    ENDCASE
    IF N_Elements(color) GT 1 THEN BEGIN
       IF N_Elements(color) NE xsize THEN $
          Message, 'COLOR vector must contain the same number of elements as the data.'
    ENDIF
    IF N_Elements(symcolor) GT 1 THEN BEGIN
       IF N_Elements(symcolor) NE xsize THEN $
          Message, 'SYMCOLOR vector must contain the same number of elements as the data.'
    ENDIF
    IF N_Elements(symsize) GT 1 THEN BEGIN
       IF N_Elements(symsize) NE xsize THEN $
          Message, 'SYMSIZE vector must contain the same number of elements as the data.'
    ENDIF
    IF N_Elements(psym) GT 1 THEN Message, 'PSYM value must be a scalar value.'
    
   ; Get current color table vectors.
   TVLCT, rr, gg, bb, /Get
   
   ; Draw the line or symbol.
   IF N_Elements(color) EQ 1 THEN BEGIN
   
       ; Load a color, if needed.
       IF Size(color, /TNAME) EQ 'STRING' THEN color = FSC_Color(color)
       CASE N_Params() OF
            1: IF psym[0] LE 0 THEN PlotS, x, Color=color, _STRICT_EXTRA=extra
            2: IF psym[0] LE 0 THEN PlotS, x, y, Color=color, _STRICT_EXTRA=extra
            3: IF psym[0] LE 0 THEN PlotS, x, y, z, Color=color, _STRICT_EXTRA=extra
       ENDCASE   
       
   ENDIF ELSE BEGIN
   
        FOR j=0,xsize-2 DO BEGIN
            thisColor = color[j]
            CASE N_Params() OF
                1: IF psym[0] LE 0 THEN BEGIN
                       PlotS, [x[0,j],x[0,j+1]], [x[1,j],x[1,j+1]], [x[2,j],x[2,j+1]], $
                           Color=thisColor, _STRICT_EXTRA=extra
                   END
                2: IF psym[0] LE 0 THEN BEGIN
                       PlotS, [x[j],x[j+1]], [y[j], y[j+1]], $
                            Color=thisColor, _STRICT_EXTRA=extra
                   ENDIF
                3: IF psym[0] LE 0 THEN BEGIN
                        PlotS, [x[j],x[j+1]], [y[j], y[j+1]], [z[j], z[j+1]], $
                            Color=thisColor, _STRICT_EXTRA=extra
                   ENDIF
            ENDCASE
        ENDFOR
   
   ENDELSE
   
   ; Draw the symbol, if required.
   IF Abs(psym) GT 0 THEN BEGIN
      
      FOR j=0,N_Elements(x)-1 DO BEGIN
      
          ; Get information about the symbol you are drawing.
          IF N_Elements(symcolor) GT 1 THEN thisColor = symcolor[j] ELSE thisColor = symcolor
          IF Size(thisColor, /TNAME) EQ 'STRING' THEN thisColor = FSC_Color(thisColor)
          IF N_Elements(symsize) GT 1 THEN thisSize = symsize[j] ELSE thisSize = symsize
          CASE N_Params() OF
              
                1: BEGIN
                   PlotS, x[*,j], COLOR=thisColor, PSYM=SymCat(Abs(psym)), $
                      SYMSIZE=thisSize, _STRICT_EXTRA=extra
                   END
                   
                2: BEGIN
                  PlotS, x[j], y[j], COLOR=thisColor, PSYM=SymCat(Abs(psym)), $
                       SYMSIZE=thisSize, _STRICT_EXTRA=extra
                   END
                   
                3: BEGIN
                   PlotS, x[j], y[j], z[j], COLOR=thisColor, PSYM=SymCat(Abs(psym)), $
                       SYMSIZE=thisSize, _STRICT_EXTRA=extra
                   END
                       
          ENDCASE  
           
       ENDFOR
       
   ENDIF 
   
   ; Restore the color table vectors.
   TVLCT, rr, gg, bb
   
END