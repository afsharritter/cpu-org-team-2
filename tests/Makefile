#Makefile for testing RSALib.s
all: run_tests_RSALib

run_tests_RSALib: test_RSALib.o RSALib.o
	gcc test_RSALib.o RSALib.o -o run_tests_RSALib

test_RSALib.o: test_RSALib.s
	gcc -c test_RSALib.s -o test_RSALib.o

RSALib.o: RSALib.s
	gcc -c RSALib.s -o RSALib.o

clean:
	rm -f *.o run_tests_RSALib
