CFLAGS = -g -O2 -flto -Wall -Wextra -Wconversion -Wno-sign-conversion -Wno-unused-parameter -std=c99

run: Runtime/norebo.c Runtime/risc-cpu.c Runtime/risc-cpu.h
	$(CC) $(CFLAGS) -o $@ Runtime/norebo.c Runtime/risc-cpu.c

clean:
	rm -f run
	rm -rf build1 build2 build3 build-risc
