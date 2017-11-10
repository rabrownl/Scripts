Add-Type -AssemblyName System.speech
$text  = [System.Convert]::FromBase64String("SGFwcHkgQmlydGhkYXkgTW90aGVyIEZ1Y2tlcg==")
$text = [System.Text.Encoding]::UTF8.GetString($text)
$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
$speak.Speak($text)