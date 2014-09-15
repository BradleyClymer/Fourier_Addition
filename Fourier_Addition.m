%   Fourier Addition; load a sound component-wise
clc, close all hidden
current_dir     = pwd                                       ;
wave_file       = 'Mario Coin.WAV'                          ;
sound_file      = fullfile( current_dir , wave_file )       ;
sound_vector    = audioread( sound_file )                   ;

L               = numel( sound_vector )                     ;
num_fft         = 2 ^ nextpow2( numel( sound_vector ) )     ;
sample_rate     = 8192 * 2                                  ;
T               = 1 / sample_rate                           ;
time_vector     = ( 1 : L ) * T                             ;
Y               = fft( sound_vector , num_fft )             ;
freq_vector     = sample_rate/2 * linspace( 0 , 1 , num_fft/2 + 1  )   ;
f_range         = 1 : 8192                                  ;
f_comp          = 8192 + f_range                            ;

figure
sp( 1 ) = subplot( 221 ) 
scatter( time_vector , sound_vector , 20 , abs( sound_vector ) )
axis tight
xlabel( 'time (s)' )
ylabel( 'amplitude' )
title( 'Original Signal' ) 

sp( 2 ) = subplot( 222 )
plot( freq_vector( f_range ) , [ real( Y( f_range ) )+100 imag( Y( f_range ) )-100 abs( Y( f_range ) ) ] )
axis tight
hold on
freq_marker = plot( [ 0 0 ] , 1e5 * [ -1 1 ] , 'YLimInclude' , 'off' )
legend( { 'Real+100' , 'Imaginary-100' , 'Magnitude' } )


subplot( 223 )
cumulative_signal   = zeros( [ num_fft 1 ] )                            ;
new_time_vector     = ( 0 : ( num_fft-1 ) ) * T                         ;
drawnow
for i = 1 : numel( Y )/2
    z                   = zeros( [ num_fft , 1 ] )                      ;
    z( i )              = Y( i )                                        ;
    if ~mod( i , 10 )
    set( freq_marker , 'XData' , freq_vector( i ) * [ 1 1 ] )           ;
    end
    y( : , i )          = real( ifft( z  , num_fft ) )                  ;
    amplitude           = sum( abs( y( : , i ) ) )                      ;
    cumulative_signal   = cumulative_signal + y( : , i )                ;
    freq_scale          = mean( cumulative_signal ) / mean( y( : , i ) );
    subplot( 223 )
    plot( new_time_vector , [ abs( cumulative_signal ) abs( y( : , i ) ) ] )
    ylim( [ 0 0.5] ) 
    if ~mod( i , 10 )
    subplot( 224 )
    title( sprintf( 'Iteration %d, Frequency %0.1f' , i , freq_vector( i ) ) )
    lower_bound         = max( 1 , i-4 )                             	;
    last_five           = real( y( : , lower_bound:i ) )            	;
    means               = mean( last_five ) + 1e-3 * [ -0.8 : 0.4 : 0.8 ];
    mean_mat            = repmat( means , [ size( last_five , 1 ) 1 ] ) ;
    last_five           = last_five - mean_mat                          ;
    plot( new_time_vector , circshift( last_five , [ 0 mod( i , 5 ) ] ) )
    xlim( [ 0 freq_vector( i )^-1 ] )
    ylim( 1e-3 * [ -1 1 ] ) 
    end
    drawnow
    if ( amplitude > 30 ) || ( ~mod( i , 100 ) )
        disp( sprintf( 'Iteration %d,\tAmplitude %0.3g' , i , sum( abs( y( : , i ) ) ) ) )
        sound( [ abs( cumulative_signal( 1 : numel( sound_vector ) ) ) freq_scale * abs( y( 1 : numel( sound_vector ) , i ) ) ] , sample_rate/2 )
        disp( abs( [ i max( y( 1 : numel( sound_vector ) , i ) ) median( y( 1 : numel( sound_vector ) , i ) ) ] ) ) 
    end
end


tightfig
set( gcf, 'OuterPosition' , [ 1 0.12 1 .98 ] )
