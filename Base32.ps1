Function Invoke-Base32Encode {
    param(
        [Parameter(Mandatory = $true)][byte[]] $ByteArray
    )

    $byteArrayAsBinaryString = -join $ByteArray.ForEach{
        [Convert]::ToString($_, 2).PadLeft(8, '0')
    }

    $Base32String = [regex]::Replace($byteArrayAsBinaryString, '.{5}', {
        param($Match)
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567'[[Convert]::ToInt32($Match.Value, 2)]
    })

    Return $Base32String
}

Function Invoke-Base32Decode {
    param(
        [Parameter(Mandatory = $true)][string] $Base32String
    )

    $bigInteger = [Numerics.BigInteger]::Zero
    
    foreach ($char in ($Base32String.ToUpper() -replace '[^A-Z2-7]').GetEnumerator()) {
        $bigInteger = ($bigInteger -shl 5) -bor ('ABCDEFGHIJKLMNOPQRSTUVWXYZ234567'.IndexOf($char))
    }

    [byte[]]$ByteArray = $bigInteger.ToByteArray()
    
    # BigInteger sometimes adds a 0 byte to the end,
    # if the positive number could be mistaken as a two's complement negative number.
    # If it happens, we need to remove it.
    if ($ByteArray[-1] -eq 0) {
        $ByteArray = $ByteArray[0..($ByteArray.Count - 2)]
    }

    # BigInteger stores bytes in Little-Endian order, 
    # but we need them in Big-Endian order.
    [array]::Reverse($ByteArray)

    Return $ByteArray
}
