/* Project Norebo
 * Copyright (C)2019 Peter De Wachter
 *
 * Released under the following notice:
 */
/*
 * Project Oberon, Revised Edition 2013
 * Copyright (C)2013 Niklaus Wirth (NW), Juerg Gutknecht (JG), Paul Reed (PR/PDR).
 *
 * Permission to use, copy, modify, and/or distribute this software and its
 * accompanying documentation (the "Software") for any purpose with or
 * without fee is hereby granted, provided that the above copyright notice
 * and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHORS DISCLAIM ALL WARRANTIES
 * WITH REGARD TO THE SOFTWARE, INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY, FITNESS AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
 * AUTHORS BE LIABLE FOR ANY CLAIM, SPECIAL, DIRECT, INDIRECT, OR
 * CONSEQUENTIAL DAMAGES OR ANY DAMAGES OR LIABILITY WHATSOEVER, WHETHER IN
 * AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE DEALINGS IN OR USE OR PERFORMANCE OF THE SOFTWARE.
 */

#ifndef RISC_CPU_H
#define RISC_CPU_H

struct RISC {
  uint32_t PC;
  uint32_t R[16];
  uint32_t H;
  bool     Z, N, C, V;
};

struct RISC_IO {
  uint32_t (*read_program)(struct RISC *risc, uint32_t adr);
  uint32_t (*read_word)(struct RISC *risc, uint32_t adr);
  uint32_t (*read_byte)(struct RISC *risc, uint32_t adr);
  void (*write_word)(struct RISC *risc, uint32_t adr, uint32_t val);
  void (*write_byte)(struct RISC *risc, uint32_t adr, uint32_t val);
};

void risc_run(const struct RISC_IO *io, struct RISC *risc);

#endif  // RISC_CPU_H
