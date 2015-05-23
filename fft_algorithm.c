#include <stdio.h>
#include <complex.h>
#include <math.h>

#define FILENAME "j1.complex.1ch.float32"
#define SAMPLE_RATE 62500000.0
#define SAMPLE_NUM 12500000.0
#define CENTER_FREQ 1.57942e9
#define WINDOW_LEN 64
#define BUFFER_LEN 1024
#define THRESHOLD 0.7

double PI;
typedef float complex cplx;

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
    cplx temp[n];
    cplx out[n];
    for (i = 0; i < n; i++) out[i] = buf[i];

    _fft(buf, out, n, 1);

	/* Flip the data across the y axis */
    for (i = 0; i < n/2; i++) temp[i+n/2] = buf[i];
    for (i = 0; i < n/2; i++) temp[i] = buf[i+n/2];
    for (i = 0; i < n; i++) buf[i] = temp[i]/n;
}

int main(){
    /* Declare and initialize variables */
    int i = 0;
    int max_i = 0;
	int trigger = 0;
    int frame_count = 0;
	int buffer_full = 0;
	int buffer_count = 0;
    int num_frame = floor(SAMPLE_NUM / WINDOW_LEN);

    double band_width, chirp_rate, min_freq, max_freq, freq, peak;
	double max = THRESHOLD;
    double time = WINDOW_LEN / SAMPLE_RATE;

    cplx buf [WINDOW_LEN];
    cplx freq_vs_time [BUFFER_LEN];

    FILE *bin_file;
    PI = atan2(1, 1) * 4;

    /* Open text file */
    bin_file = fopen(FILENAME, "rb");
    if(bin_file != NULL){
        while (frame_count < num_frame){

			/* If the detector isn't triggered, the algorithm will keep /
			/  performing small FFTs and checking if the peak energy is /
			/  above the designated threshold.                         */
            if (trigger == 0){
                fread(buf, sizeof(buf), 1, bin_file);
                fft(buf, WINDOW_LEN);
                for (i = 0; i < WINDOW_LEN; i++){
//                    peak = cabs(buf[i]);
                    peak = (10 * log10(pow(cabs(buf[i]), 2))) + 30;
                    if (peak > max){
                        max = peak;
                        max_i = i;
                    }
                }

                if (max > THRESHOLD){
					/* Trigger the detector, overwrite the buffer and record time */
                    trigger = 1;
                    buffer_count = 0;
					time = frame_count * WINDOW_LEN / SAMPLE_RATE;

					/* Record the frequency corresponding to the maximum energy */
                    freq = max_i * (SAMPLE_RATE / WINDOW_LEN) - (SAMPLE_RATE/2.0) + CENTER_FREQ;
                    freq_vs_time[buffer_count] = freq + 0*I;
                    buffer_count += 1;
                    max = THRESHOLD;
                }
            }

			/* If the detector has already been triggered it will continue to run /
			/  FFTs until it has filled the time vs. frequency array.            */
            else{
                fread(buf, sizeof(buf), 1, bin_file);
                fft(buf, WINDOW_LEN);
                for (i = 0; i < WINDOW_LEN; i++){
//                    peak = cabs(buf[i]);
                    peak = (10 * log10(pow(cabs(buf[i]), 2))) + 30;
                    if (peak > max){
                        max = peak;
                        max_i = i;
                    }
                }

				freq = max_i * (SAMPLE_RATE / WINDOW_LEN) - (SAMPLE_RATE/2.0) + CENTER_FREQ;
                freq_vs_time[buffer_count] = freq + 0*I;
                buffer_count += 1;
                max = THRESHOLD;
                if (buffer_count == BUFFER_LEN) buffer_full = 1;
            }

			/* Once the time vs. frequency array is full the detector will analyze the data /
			/  to determine the chirp rate and bandwidth.                                  */
            if (buffer_full == 1){
				/* Reset max, buffer status and trigger status*/
                max = THRESHOLD;
                buffer_full = 0;
                trigger = 0;

				/* Find max and min frequency to determine bandwidth */
                min_freq = CENTER_FREQ + SAMPLE_RATE/2.0;
                max_freq = CENTER_FREQ - SAMPLE_RATE/2.0;
                for (i = 0; i < BUFFER_LEN; i++){
                    freq = creal(freq_vs_time[i]);
                    if (freq > max_freq){
                        max_freq = freq_vs_time[i];
                    }
                    if (freq < min_freq){
                        min_freq = freq_vs_time[i];
                    }
                }
                band_width = max_freq - min_freq;

				/* Perform FFT on the frequency vs time array to calculate the chirp rate */
                fft(freq_vs_time, BUFFER_LEN);
                freq_vs_time[BUFFER_LEN/2] = 0; 	/* Delete the DC value of the result */

				/* Find the  */
                max_freq = -10000;
                for (i = 0; i < BUFFER_LEN; i++){
                    freq = cabs(freq_vs_time[i]);
                    if (freq > max_freq){
                        max_freq = freq;
                        max_i = i;
                    }
                }

                chirp_rate = (SAMPLE_RATE / BUFFER_LEN) * (max_i - (BUFFER_LEN / 2.0));
				if(chirp_rate < 0) chirp_rate = -1.0 * chirp_rate;

				/* Display detection results */
				printf("Triggered at t = %.6f seconds\t", time);
                printf("Bandwidth = %.3e Hz\t", band_width);
                printf("Chirp rate =  %.3e Hz\n", chirp_rate);
            }
            frame_count += 1;
        }
        printf("\nEnd of capture.");
        fclose(bin_file);
    }
    else{
            printf("Error opening file!");
    }
    return 0;
}
/* ---------------------------------------------- */
