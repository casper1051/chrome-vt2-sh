
echo "You are making unsupported changes to your usb. Make a backup first."

echo -n "Are you sure you want to proceed? (Double tap y, any other key exits): "

confirm() {

	IFS= read -r -n1 c1
	if [[ "$c1" =~ ^[yY]$ ]]; then
		IFS= read -r -n1 c2
		if [[ "$c2" =~ ^[yY]$ ]]; then
			echo ""
			return 0
		fi
	fi
	echo -e "\nExiting"
	exit 1
}

confirm

touch /root/.test_write 2>/dev/null

if [[ ! -f /root/.test_write ]]; then
	echo "Test write failed, make sure your /root/ directory is writable. This shouldn't happen" >&2
	exit 1
fi

lsblk

read -e -r -p "Please enter your target kernel partition (for shimboot this is usually /dev/sdX2 or /dev/mmcblkXp2):" part

if [[ ! -b "$part" ]]; then
	echo "Partition does not exist or device is missing. Check you did not make a typo and device is listed above"
	exit 1
fi

cd /root/

mkdir /root/kernel_resigning

cd kernel_resigning

#ima do this later

#if [[ ! -f ./shim_kern.orig ]]; then
#	echo "Backup file not found. Backup kernel now? " >&2
#	exit 1
#fi

#also add restoring later

#dd if=./shim_kern.orig of=/dev/mmcblk1p2

KEYDIR=/usr/share/vboot/devkeys

if [[ ! -f "$KEYDIR/recovery_kernel.keyblock" ]]; then
	echo "Keyblock not found. This should not happen."
	exit 1
fi

if [[ ! -f "$KEYDIR/recovery_kernel_data_key.vbprivk" ]]; then
	echo "Private kernel data key not found. This should not happen."
	exit 1
fi

futility dump_kernel_config $part > /root/kernel_resigning/shim_config.txt

echo "Resigning..."

kernver=$(crossystem tpm_kernver)

dec=$(( ${kernver#0x} ))

echo "Using kernver $dec"

futility vbutil_kernel \
--repack "$part"  \
--keyblock "$KEYDIR/recovery_kernel.keyblock" \
--signprivate "$KEYDIR/recovery_kernel_data_key.vbprivk" \
--config ./shim_config.txt \
--version "$dec" \
--oldblob "$part"

futility vbutil_kernel --verify $part

echo "if it doesn't say body verification succeeded somewhere above this text then it didn't work"
