<CODEGEN_FILENAME>ConfigureReplication.dbl</CODEGEN_FILENAME>
;;*****************************************************************************
;;
;; File:        ConfigureReplication.dbl
;;
;; Description: Adds replication I/O hooks to channels
;;
;;*****************************************************************************
;;
;; Copyright (c) 2016, Synergex International, Inc.
;; All rights reserved.
;;
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions are met:
;;
;; * Redistributions of source code must retain the above copyright notice,
;;   this list of conditions and the following disclaimer.
;;
;; * Redistributions in binary form must reproduce the above copyright notice,
;;   this list of conditions and the following disclaimer in the documentation
;;   and/or other materials provided with the distribution.
;;
;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;; ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
;; LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
;; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
;; SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
;; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
;; CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
;; ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;; POSSIBILITY OF SUCH DAMAGE.
;;

import <NAMESPACE>

subroutine ConfigureReplication
	required in channel, n
	endparams

	stack record
		openMode, a3
		fileSpec, a128
		fileName, a80
		fileExt,  a20
	endrecord

	.define common global common
	.include "INC:sqlgbl.def"
	.undefine common

	external function
		doFile, boolean
	endexternal

proc
	;;Get the file spec from the open channel
	xcall filnm(channel,fileSpec)
	xcall parse(fileSpec,,,,,fileName,fileExt)
	fileSpec = %atrim(fileName) + fileExt
	upcase fileSpec

	;;Default to NOT populating a REPLICATION_KEY field for this channel
	repkey_required[channel] = 0

	;;Get the open mode of the channel
	xcall getfa(channel,"OMD",openMode)

	using openMode select
	("U:I"),
	begin
		using fileSpec select

;       ;;A single-record layout file that already had a unique key
;       ("FILE1.ISM"),
;           new ReplicationIoHooks(channel,"FILE1")
;
;       ;;A single-record layout file with REPLICATION_KEY added
;       ("FILE2.ISM"),
;       begin
;           new ReplicationIoHooks(channel,"FILE2")
;           repkey_required[channel] = 1
;       end
;
;       ;;A multi-record layout file that already had a unique key
;       ("FILE3.ISM"), ;;Multiple possibilities (FILE3A, FILE3B, FILE3C)
;           new ReplicationIoHooks(channel,"MULTI_FILE3")
;
;       ;;A multi-record layout file with REPLICATION_KEY added
;       ("FILE4.ISM"), ;;Multiple possibilities (FILE4A, FILE4B, FILE4C)
;       begin
;           new ReplicationIoHooks(channel,"MULTI_FILE4")
;           repkey_required[channel] = 1
;       end

		("EMPLOYEE.ISM"),
			new ReplicationIoHooks(channel,"EMPLOYEE")

		endusing
	end
	("U:R"),
	begin
		using fileSpec select

;		;;A relative file
;       ("FILE1.DDF"),
;           new ReplicationIoHooksRel(channel,"FILE1")

		endusing
	end
	endusing

	xreturn

endsubroutine