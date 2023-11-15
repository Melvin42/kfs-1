NAME = kfs.bin

ISONAME = kfs.iso

LDFILE = linker.ld

LDFLAGS = -m elf_i386 -T

ASM = nasm

SFLAGS = -felf32

SRC = boot.s kernel.s

OBJ = ${SRC:.s=.o}

.s.o:
	$(ASM) $(SFLAGS) $< -o $@

all : $(NAME) $(ISONAME)

$(NAME) : $(OBJ)
	ld $(LDFLAGS) $(LDFILE) -o $(NAME) $(OBJ)

$(ISONAME) : $(NAME)
	mkdir -p isodir/boot/grub
	cp $(NAME) isodir/boot/$(NAME)
	cp grub.cfg isodir/boot/grub/grub.cfg
	grub-mkrescue -o $(ISONAME) isodir

clean :
	rm -f $(OBJ)
	rm -rf isodir

fclean : clean
	rm -f $(NAME)
	rm -f $(ISONAME)

re : fclean all

.PHONY : all clean fclean re .s.o
