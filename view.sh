#!/usr/bin/env bash

function delayedfirefox {
	sleep 1
	firefox localhost:1313
}
delayedfirefox &
hugo -D --i18n-warnings server
