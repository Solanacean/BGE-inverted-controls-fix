; Patching macros 
; v0.60 
; for flat assembler by Grom PE 

; How it works: 
; - File name and size are specified with "patchfile" 
; - On every "patchat", part of file is loaded and added, 
;   (or zeroes if file is ended) assembling point moves to 
;   specified offset. 
; - On "patchend", if there part of file left, it is added. 
; - "patchsection x" makes every following "patchat" macro 
;   act like "org x" was placed after it. 

; Notes: 
; - Don't use "org" directive between all patching macros! 

;  For good example on how to use patching macros look: 
;  http://board.flatassembler.net/topic.php?t=8876 

p_savedorg = 0 
p_sectionset = 0 

macro pushorg value* 
{ 
  p_wasorg = $ 
  org value 
  p_inorg = $ 
  p_savedorg = 1 
} 

macro poporg 
{ 
  local orgsize 
  orgsize = $ - p_inorg 
  org p_wasorg + orgsize 
  p_savedorg = 0 
} 

macro patchsection value* 
{ 
  p_sectionset = 1 
  p_sectionorg = value 
} 

macro patchfile name* 
{ 
  virtual 
    @@: 
    file name 
    p_filesize = $ - @b 
  end virtual 
  p_start = $ 
  p_pointer = 0 
  p_filename equ name 
} 

macro patchat address* 
{ 
  if p_savedorg = 1 
    poporg 
  end if 

  p_pointer = p_pointer - p_start + $ 
  p_toadd = address - $ 

  if address >= 0 
    if p_toadd >= 0 
      if p_pointer + p_toadd <= p_filesize 
        file p_filename: p_pointer, p_toadd 
      else 
        p_addpart = 0 
        if p_pointer < p_filesize 
          p_addpart = p_filesize - p_pointer 
          file p_filename: p_pointer, p_addpart 
        end if 
        rb p_toadd - p_addpart 
      end if 
    else 
      "Error: can't move backwards." 
    end if 
  else 
    "Error: invalid address, must be >= 0." 
  end if 

  p_start = $ 
  p_pointer = p_pointer + p_toadd 

  if p_sectionset = 1 
    pushorg p_sectionorg + address 
  end if 
} 

macro patchend 
{ 
  if p_savedorg 
    poporg 
  end if 

  p_pointer = p_pointer - p_start + $ 
  p_toadd = p_filesize - $ 

  if p_toadd >= 0 
    if p_pointer + p_toadd <= p_filesize 
      file p_filename: p_pointer, p_toadd 
    else 
      p_addpart = 0 
      if p_pointer < p_filesize 
        p_addpart = p_filesize - p_pointer 
        file p_filename: p_pointer, p_addpart 
      end if 
      db p_toadd - p_addpart dup 0 
    end if 
  end if 
}
