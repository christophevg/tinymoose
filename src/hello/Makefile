TARGET=Hello
COMPONENT=${TARGET}C
APP=${TARGET}AppC
TINYOS_ROOT_DIR?=../../tinyos-main
BUILD_DIR=build
CC=../../nesc/src/nesc1
MOOSE_DIR=../../

all: ${BUILD_DIR}/main.c ${BUILD_DIR}/Makefile
	@echo "*** building ${TARGET} example..."
	@(cd ${BUILD_DIR}; make)

${BUILD_DIR}:
	@mkdir -p ${BUILD_DIR}

%/main.c: % ${COMPONENT}.nc ${APP}.nc
	@echo "*** constructing $@ for ${TARGET} example..."
	@${CC} -U__BLOCKS__ \
				 -fnesc-include=deputy_nodeputy \
				 -fnesc-gcc=avr-gcc \
				 -mmcu=atmega128 \
				 -DPLATFORM_MICA2 \
				 -DIDENT_APPNAME="${APP}" \
				 -DNESC=136 \
				 -I/usr/local/lib/ncc \
				 -I../../ \
				 -I../../tinyos-main/tos/platforms/mica2 \
				 -I../../tinyos-main/tos/platforms/mica \
				 -I../../tinyos-main/tos/platforms/mica2/chips/cc1000 \
				 -I../../tinyos-main/tos/chips/cc1000 \
				 -I../../tinyos-main/tos/platforms/mica2/chips/at45db \
				 -I../../tinyos-main/tos/platforms/mica/chips/at45db \
				 -I../../tinyos-main/tos/chips/at45db \
				 -I../../tinyos-main/tos/chips/atm128 \
				 -I../../tinyos-main/tos/chips/atm128/adc \
				 -I../../tinyos-main/tos/chips/atm128/i2c \
				 -I../../tinyos-main/tos/chips/atm128/pins \
				 -I../../tinyos-main/tos/chips/atm128/spi \
				 -I../../tinyos-main/tos/chips/atm128/timer \
				 -I../../tinyos-main/tos/lib/timer \
				 -I../../tinyos-main/tos/lib/serial \
				 -I../../tinyos-main/tos/lib/power \
				 -I../../tinyos-main/tos/system \
				 -I../../tinyos-main/tos/types \
				 -I../../tinyos-main/tos/interfaces \
				 -Wall \
				 -Wshadow \
				 -Wno-unused-but-set-variable \
				 -Wno-enum-compare \
				 -v \
				 -fnesc-tmpcfile=temp.c \
				 -fnesc-include=nesc_nx \
				 -Wnesc-all \
				 -fnesc-include=tos \
				 -fnesc-scheduler=TinySchedulerC,TinySchedulerC.TaskBasic,TaskBasic,TaskBasic,runTask,postTask \
				 -fnesc-separator=__ \
				 -fnesc-target=avr \
				 -fnesc-no-debug \
				${APP}.nc \
				-o $@ > .nesc.generation.log 2>&1

%/Makefile: %
	@echo "*** adding Makefile to build ${TARGET} example..."
	@echo "USE_MOOSE=avr serial" > $@
	@echo "include ../../Makefile.include" >> $@

clean:
	@rm -rf ${BUILD_DIR}

											
											
											
											
											
											