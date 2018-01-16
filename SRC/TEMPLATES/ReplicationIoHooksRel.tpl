<CODEGEN_FILENAME>ReplicationIoHooksRel.dbl</CODEGEN_FILENAME>
;//*****************************************************************************
;//
;// Title:      ReplicationIoHooksRel.tpl
;//
;// Description:Template to generate an IO Hooks class for use with SQL replication
;//             of relative files.
;//
;// Author:     Steve Ives, Synergex Professional Services Group
;//
;// Copyright   � 2018 Synergex International Corporation.  All rights reserved.
;//
;;*****************************************************************************
;;
;; File:        ReplicationIoHooksRel.dbl
;;
;; Type:        Class (ReplicationIoHooksRel)
;;
;; Description: An I/O Hooks class that implements SQL data replication for relative files
;;
;;*****************************************************************************
;;
;; Copyright (c) 2018, Synergex International, Inc.
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
;;*****************************************************************************
;; WARNING: THIS CODE WAS CODE GENERATED AND WILL BE OVERWRITTEN IF CODE
;;          GENERATION IS RE-EXECUTED FOR THIS PROJECT.
;;*****************************************************************************

import Synergex.SynergyDE.IOExtensions
import Synergex.SynergyDE.Select

namespace <NAMESPACE>

    ;;-------------------------------------------------------------------------
    ;;I/O hooks class that implements SQL Replication for relative files
    ;;
    public sealed class ReplicationIoHooksRel extends IOHooks

        private mTableName, string
        private mActive, boolean, false
        private mChannel, int, 0

        ;;---------------------------------------------------------------------
        ;;Constructor

        public method ReplicationIoHooksRel
            required in aChannel, n
            required in aTableName, string
            endparams
            parent(aChannel)
            record
                openMode, a3
            endrecord
            .ifdef D_VMS
            .include "REPLICATION_VMS" repository, structure="strInstruction", end
            .else
            .include "REPLICATION" repository, structure="strInstruction", end
            .endc
        proc
            ;;Make sure the channel is to a relative file and open in update mode
            xcall getfa(aChannel,"OMD",openMode)

            if (openMode=="U:R")
            begin
                ;;Check that the record length is not over the maximum we can support
                data recLen, int
                xcall getfa(aChannel,"RSZ",recLen)
                if (recLen > ^size(strInstruction.record))
                    exit

                ;;Record the channel number and structure name
                mChannel = aChannel
                mTableName = aTableName
                mActive = true
            end
        endmethod

        ;;---------------------------------------------------------------------
        ;;WRITE hooks

        public override method write_post_operation_hook, void
            required inout       aRecord, a
            optional in          aRecnum, n
            optional in          aRfa,    a
            required in          aFlags,  IOFlags
            required inout       aError,  int
            endparams
        proc
            ;;A record was just written. If it changed then replicate the change.
            if (mActive && !aError)
                xcall replicate(REPLICATION_INSTRUCTION.UPDATE_RELATIVE,mTableName,%string(aRecnum)+":"+aRecord)
        endmethod

        ;;-------------------------------------------------------------------------------------

    endclass

endnamespace
