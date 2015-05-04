TARGET=Hello
COMPONENT=${TARGET}C
APP=${TARGET}AppC
TINYOS_ROOT_DIR?=/Users/xtof/Workspace/tinyos-main
BUILD_DIR=build

all: ${BUILD_DIR}/app.c

${BUILD_DIR}:
	mkdir -p ${BUILD_DIR}

%/app.c: % ${COMPONENT}.nc ${APP}.nc
	nescc -o /dev/null \
				-Os \
				-gcc=avr-gcc \
				-Wnesc-all \
				-fnesc-include=tos \
				-fnesc-scheduler=TinySchedulerC,TinySchedulerC.TaskBasic,TaskBasic,TaskBasic,runTask,postTask \
				-fnesc-cfile=$</app.c \
				-fnesc-separator=__ \
				-I${TINYOS_ROOT_DIR}/tos/platforms/mica2 \
				-I${TINYOS_ROOT_DIR}/tos/platforms/mica \
				-I${TINYOS_ROOT_DIR}/tos/platforms/mica2/chips/cc1000 \
				-I${TINYOS_ROOT_DIR}/tos/chips/cc1000 \
				-I${TINYOS_ROOT_DIR}/tos/platforms/mica2/chips/at45db \
				-I${TINYOS_ROOT_DIR}/tos/platforms/mica/chips/at45db \
				-I${TINYOS_ROOT_DIR}/tos/chips/at45db \
				-I${TINYOS_ROOT_DIR}/tos/chips/atm128 \
				-I${TINYOS_ROOT_DIR}/tos/chips/atm128/adc \
				-I${TINYOS_ROOT_DIR}/tos/chips/atm128/i2c \
				-I${TINYOS_ROOT_DIR}/tos/chips/atm128/pins \
				-I${TINYOS_ROOT_DIR}/tos/chips/atm128/spi \
				-I${TINYOS_ROOT_DIR}/tos/chips/atm128/timer \
				-I${TINYOS_ROOT_DIR}/tos/lib/timer \
				-I${TINYOS_ROOT_DIR}/tos/lib/serial \
				-I${TINYOS_ROOT_DIR}/tos/lib/power \
				-I${TINYOS_ROOT_DIR}/tos/system \
				-I${TINYOS_ROOT_DIR}/tos/types \
				-I${TINYOS_ROOT_DIR}/tos/interfaces \
				-mmcu=atmega128 \
				-fnesc-target=avr \
				-fnesc-no-debug \
				-DPLATFORM_MICA2 \
				-Wall \
				-Wshadow \
				--param max-inline-insns-single=100000 \
				-Wno-unused-but-set-variable \
				-Wno-enum-compare \
				-DIDENT_APPNAME=\"${APP}\" \
				${APP}.nc \
				-lm

clean:
	rm -rf ${BUILD_DIR}
