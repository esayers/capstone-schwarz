#ifndef JAMDETECT_H
#define JAMDETECT_H

#include <complex.h>
#include <math.h>
#include "prot_malloc.h"

#define PI 3.14159265358979323846
#define THRESHOLD 0.7
#define WIN_SIZE 64
#define BUFFER_LEN 1024

typedef float complex cplx;

typedef struct win_peak {
    float value;
    float freq;
    int valid;
} win_peak;

typedef struct jam_info {
	float time;
	float bandwidth;
	float chirprate;
	int valid;
} jam_info;

typedef struct time_info {
	int trigger;
	unsigned int time;
	int index;
	cplx * freq_vs_time;
} time_info;

void _fft(cplx *, cplx *, int, int);
void fft(cplx *, int);
win_peak get_peak(cplx *, int, float, float);
jam_info process_signal(win_peak, float, time_info *);
void uninter(float *, cplx *, int);
void blackman_harris(float *, int);

#endif
