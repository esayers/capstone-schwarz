#include "jamdetect.h"
#include "platform_gpio.h"
#include "FreeRTOS.h"
#include "semphr.h"

void _fft(cplx buf[], cplx out[], int n, int step){
    int i;
    if (step < n) {
        _fft(out, buf, n, step * 2);
        _fft(out + step, buf + step, n, step * 2);

        for (i = 0; i < n; i += 2 * step){
                cplx t = cexpf(-I * PI * i / n) * out[i + step];
                buf[i / 2]     = out[i] + t;
                buf[(i + n)/2] = out[i] - t;
        }
    }
}

void fft(cplx buf[], int n){
    int i;

    cplx *out = prot_mem_malloc(sizeof(cplx) * n);


    for (i = 0; i < n; i++) out[i] = buf[i];

    _fft(buf, out, n, 1);

        /* Flip the data across the y axis */
    for (i = 0; i < n/2; i++) out[i+n/2] = buf[i];
    for (i = 0; i < n/2; i++) out[i] = buf[i+n/2];
    for (i = 0; i < n; i++) buf[i] = out[i]/n;

    prot_mem_free(out);

}

win_peak get_peak(cplx buf[], int nsamples, float sample_rate, float center_freq)
{
    int i;
    float max, cur;
    win_peak peak;
    int index;

    max = THRESHOLD;

    peak.valid = 0;
    for (i = 0; i < nsamples; ++i)
    {
        cur = cabs(buf[i]);
        if (cur > max)
        {
            max = cur;
            index = i;
            peak.valid = 1;
        }
    }


    peak.value = max;//(10 * log10(pow(max, 2))) + 30;
    peak.freq = index * (sample_rate / nsamples) - (sample_rate/2.0) + center_freq;

    return peak;
}


jam_info process_signal(win_peak peak, float sample_rate, time_info *time)
{
	jam_info rv;
	float min = INFINITY;
	float max = -INFINITY;
	float max_freq = -INFINITY;
	float freq;
	int i, max_i;

	rv.valid = 0;

	++time->time;
	/* Skip if not time->triggered and peak is below threshold */
	if (!time->trigger && peak.value <= THRESHOLD)
	{
		return rv;
	}

	time->trigger = 1;
	if (time->index == 0)
	{
		time->freq_vs_time = prot_mem_malloc(sizeof(cplx) * BUFFER_LEN);
		clear_led(0);
	}

	if (peak.valid)
		time->freq_vs_time[time->index] = peak.freq + 0 * I;
	else
		time->freq_vs_time[time->index] = time->freq_vs_time[time->index - 1];

	++(time->index);

	if (time->index == BUFFER_LEN)
	{
		for (i = 0; i < BUFFER_LEN; ++i)
		{
			freq = creal(time->freq_vs_time[i]);
			min = fmin(min, freq);
			max = fmax(max, freq);
		}

        fft(time->freq_vs_time, BUFFER_LEN);
        time->freq_vs_time[BUFFER_LEN/2] = 0;         /* Delete the DC value of the result */

        for (i = 0; i < BUFFER_LEN; i++){
            freq = cabs(time->freq_vs_time[i]);
            if (freq > max_freq){
            	max_freq = freq;
                max_i = i;
            }
         }

		rv.bandwidth = max - min;
		rv.chirprate = (sample_rate / WIN_SIZE) * (2.0 * max_i - (BUFFER_LEN / 2.0) / (2.0 * BUFFER_LEN));
		rv.time = time->time / (sample_rate / 64000);
		if (rv.bandwidth != 0.0)
			rv.valid = 1;
		time->trigger = 0;
		time->index = 0;
		set_led(0);
		prot_mem_free(time->freq_vs_time);
	}

 return rv;
}

void uninter(float * in, cplx * out, int n)
{
		int i, realclass, imagclass;
		float real, imag;

		/* Fill complex buffer from body */
		for (i = 0; i < n; ++i)
		{
			real = in[i * 2];
			imag = in[i * 2 + 1];

			realclass = fpclassify(real);
			imagclass = fpclassify(imag);

			if (realclass == FP_NAN || realclass == FP_INFINITE)
				real = 0.0f;

			if (imagclass == FP_NAN || imagclass == FP_INFINITE)
				imag = 0.0f;

			 out[i] = real + imag * I;
		}
}

/* Blackman Harris windowing function declaration */
void blackman_harris(float win[], int L){
    int i;
    int N = L - 1;
    for(i = 0; i < N; i++){
        win[i] = 0.35875 - 0.48829*cos(2*PI*i/N) + 0.14128*cos(4*PI*i/N) - 0.01168*cos(6*PI*i/N);
    }
}
