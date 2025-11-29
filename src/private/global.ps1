# Path for configuration files
if ($IsWindows) {
	$SignalConfigFile = [System.IO.FileInfo]::new((Join-Path $env:LOCALAPPDATA "Signal Module" "SignalConfig.xml"))
}elseif ($isLinux -or $IsMacOS) {
	$SignalConfigFile = [System.IO.FileInfo]::new((Join-Path $HOME ".signalmodule" "SignalConfig.xml"))
} else {
	Write-Host "is Windows: $isWindows"
	Write-Host "is Linux: $isLinux"
	Write-Host "is MacOS: $IsMacOS"
	Write-Error "Not supported operating system"
	exit(3)
}


$ImageExtensions = @('aces', 'apng', 'avci', 'avcs', 'avif', 'bmp', 'cgm', 'dpx', 'emf', 'example', 'fits', 'g3fax', 'gif', 'heic', 'heif', 'hej2k', 'ief', 'j2c', 'jaii', 'jais', 'jls', 'jp2', 'jpg','jpeg', 'jph', 'jphc', 'jpm', 'jpx', 'jxl', 'jxr', 'jxrA', 'jxrS', 'jxs', 'jxsc', 'jxsi', 'jxss', 'ktx', 'ktx2', 'naplps', 'png', 'svg+xml', 't38', 'tiff', 'tiff-fx', 'webp', 'wmf')
$TextExtensions = @('cache-manifest', 'calendar', 'cql', 'cql-expression', 'cql-identifier', 'css', 'csv', 'csv-schema', 'dns', 'encaprtp', 'enriched', 'example', 'fhirpath', 'flexfec', 'fwdred', 'gff3', 'grammar-ref-list', 'hl7v2', 'html', 'javascript', 'jcr-cnd', 'markdown', 'mizar', 'n3', 'parameters', 'parityfec', 'plain', 'provenance-notation', 'raptorfec', 'RED', 'rfc822-headers', 'richtext', 'rtf', 'rtp-enc-aescm128', 'rtploopback', 'rtx', 'SGML', 'shaclc', 'shex', 'spdx', 'strings', 't140', 'tab-separated-values', 'troff', 'turtle', 'ulpfec', 'uri-list', 'vcard', 'vtt', 'wgsl', 'xml', 'xml-external-parsed-entity')
$VideoExtensions = @('3gpp', '3gpp2', '3gpp-tt', 'AV1', 'BMPEG', 'BT656', 'CelB', 'DV', 'encaprtp', 'evc', 'example', 'FFV1', 'flexfec', 'H261', 'H263', 'H263-1998', 'H263-2000', 'H264', 'H264-RCDO', 'H264-SVC', 'H265', 'H266', 'iso.segment', 'jxsv', 'lottie+json', 'matroska', 'matroska-3d', 'mj2', 'MP1S', 'MP2P', 'MP2T', 'mp4', 'MP4V-ES', 'MPV', 'mpeg', 'mpeg4-generic', 'nv', 'ogg', 'parityfec', 'pointer', 'quicktime', 'raptorfec', 'raw', 'rtp-enc-aescm128', 'rtploopback', 'rtx', 'scip', 'smpte291', 'SMPTE292M', 'ulpfec', 'vc1', 'vc2', 'VP8', 'VP9')
