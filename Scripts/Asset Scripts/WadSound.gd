extends Node

class_name WadSound

var data = []
var stream = AudioStream.new()

func parse(f, size, asset):
	data = f.get_buffer(size)
	var bytes = data
	var newstream = null
	var audio_print=false
	# if File is wav
	if asset.ends_with(".wav"):
		newstream = AudioStreamSample.new()
		#---------------------------
		#parrrrseeeeee!!! :D
		var i = 0
		var riff_found = false
		var wave_found = false
		var fmt_found = false
		var data_found = false
		while i < len(bytes) and !(riff_found and wave_found and fmt_found and data_found):
			var those4bytes = str(char(bytes[i])+char(bytes[i+1])+char(bytes[i+2])+char(bytes[i+3]))
			
			if those4bytes == "RIFF": 
				if audio_print:
					print ("RIFF OK at bytes " + str(i) + "-" + str(i+3))
				#RIP bytes 4-7 integer for now
				i += 8
				riff_found = true
				continue
			if those4bytes == "WAVE": 
				if audio_print:
					print ("WAVE OK at bytes " + str(i) + "-" + str(i+3))
				i += 4
				wave_found = true
				continue

			if those4bytes == "fmt ":
				if audio_print:
					print ("fmt OK at bytes " + str(i) + "-" + str(i+3))
				
				#get format subchunk size, 4 bytes next to "fmt " are an int32
				var formatsubchunksize = bytes[i+4] + (bytes[i+5] << 8) + (bytes[i+6] << 16) + (bytes[i+7] << 24)
				if audio_print:
					print ("Format subchunk size: " + str(formatsubchunksize))
				
				#using formatsubchunk index so it's easier to understand what's going on
				i += 8
				var fsc0 = i #fsc0 is byte 8 after start of "fmt "

				#get format code [Bytes 0-1]
				var format_code = bytes[fsc0] + (bytes[fsc0+1] << 8)
				var format_name
				if format_code == 0: format_name = "8_BITS"
				elif format_code == 1: format_name = "16_BITS"
				elif format_code == 2: format_name = "IMA_ADPCM"
				if audio_print:
					print ("Format: " + str(format_code) + " " + format_name)
				#assign format to our AudioStreamSample
				newstream.format = format_code
				
				#get channel num [Bytes 2-3]
				var channel_num = bytes[fsc0+2] + (bytes[fsc0+3] << 8)
				if audio_print:
					print ("Number of channels: " + str(channel_num))
				#set our AudioStreamSample to stereo if needed
				if channel_num == 2: newstream.stereo = true
				
				#get sample rate [Bytes 4-7]
				var sample_rate = bytes[fsc0+4] + (bytes[fsc0+5] << 8) + (bytes[fsc0+6] << 16) + (bytes[fsc0+7] << 24)
				if audio_print:
					print ("Sample rate: " + str(sample_rate))
				#set our AudioStreamSample mixrate
				newstream.mix_rate = sample_rate
				
				#get byte_rate [Bytes 8-11] because we can
				var byte_rate = bytes[fsc0+8] + (bytes[fsc0+9] << 8) + (bytes[fsc0+10] << 16) + (bytes[fsc0+11] << 24)
				if audio_print:
					print ("Byte rate: " + str(byte_rate))
				
				#same with bits*sample*channel [Bytes 12-13]
				var bits_sample_channel = bytes[fsc0+12] + (bytes[fsc0+13] << 8)
				if audio_print:
					print ("BitsPerSample * Channel / 8: " + str(bits_sample_channel))
				#aaaand bits per sample [Bytes 14-15]
				var bits_per_sample = bytes[fsc0+14] + (bytes[fsc0+15] << 8)
				if audio_print:
					print ("Bits per sample: " + str(bits_per_sample))
				i += 16
				fmt_found = true
				continue
				
			if those4bytes == "data":
				var audio_data_size = bytes[i+4] + (bytes[i+5] << 8) + (bytes[i+6] << 16) + (bytes[i+7] << 24)
				if audio_print:
					print ("Audio data/stream size is " + str(audio_data_size) + " bytes")

				i += 8
				var data_entry_point = i
				if audio_print:
					print ("Audio data starts at byte " + str(data_entry_point))
				
				newstream.data = bytes.subarray(data_entry_point, data_entry_point+audio_data_size-1)
				i += audio_data_size
				i += 4
				data_found = true
				continue
			i += 1
			# end of parsing
			#---------------------------

		#get samples and set loop end
		var samplenum = newstream.data.size() / 4
		newstream.loop_end = samplenum
		newstream.loop_mode = 0 #change to 0 or delete this line if you don't want loop, also check out modes 2 and 3 in the docs

	#if file is ogg
	elif asset.ends_with(".ogg"):
		newstream = AudioStreamOGGVorbis.new()
		newstream.loop = false #set to false or delete this line if you don't want to loop
		newstream.data = bytes

	#if file is mp3
	elif asset.ends_with(".mp3"):
		newstream = AudioStreamMP3.new()
		newstream.loop = true #set to false or delete this line if you don't want to loop
		newstream.data = bytes
#		newstream.set_data(bytes)

	else:
		print ("ERROR: audio preview failed")
#			return null
		stream = null
	stream = newstream
	return self


func write(f):
	f.store_buffer(data)

