# Echo Dot Bluetooth fix (Fedora 45 / BlueZ 5.86+)

Amazon Echo Dot connects over Bluetooth but audio never starts, or keeps
dropping, on Fedora 45. It worked on Fedora 44 and on Windows.

## Symptoms

`journalctl -u bluetooth` repeats:

```
profiles/audio/avdtp.c:cancel_request() SetConfiguration: Connection timed out (110)
profiles/audio/avdtp.c:avdtp_parse_rej() SET_CONFIGURATION request rejected: Stream End Point in Use (19)
```

and WirePlumber logs `Failure in Bluetooth audio transport`.

## Cause

The Echo Dot is a two-way device: it is both an A2DP sink (speaker) and an
A2DP source (it can stream to the PC). BlueZ 5.86 changed the order profiles
connect in, so the PC and the Echo both try to configure an audio stream at
the same time and block each other. Fedora 44 shipped an older BlueZ.

## Fix

Stop the PC from offering the A2DP sink role, so audio only goes PC → Echo.
`51-bluetooth-output-only.conf` sets WirePlumber's `bluez5.roles` without
`a2dp_sink`.

```
./install.sh
```

or copy the file to `~/.config/wireplumber/wireplumber.conf.d/` and run
`systemctl --user restart wireplumber`.

Side effect: the PC can no longer act as a Bluetooth speaker for a phone.

## Undo

```
rm ~/.config/wireplumber/wireplumber.conf.d/51-bluetooth-output-only.conf
systemctl --user restart wireplumber
```

## Tested on

- Fedora 45, kernel 7.3.3
- BlueZ 5.88, PipeWire 1.6.11, WirePlumber 0.5.19
- MediaTek MT7921 Bluetooth

## References

- [Two-way Bluetooth speakers broken in BlueZ 5.86](https://discuss.cachyos.org/t/fix-2-way-bluetooth-speakers-do-not-a2dp-sink-in-bluez-5-86-downgrade-to-5-85/24107)
- [Amazon Echo stopped working as speaker after BlueZ 5.86](https://discuss.cachyos.org/t/bluetooth-speaker-amazon-echo-stopped-working-as-speaker-after-bluez-5-86/23163/11)
- [Fedora Bugzilla 2397966](https://bugzilla.redhat.com/show_bug.cgi?id=2397966)
