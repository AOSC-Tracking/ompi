# -*- shell-script -*-
#
# Copyright (c) 2009-2015 Cisco Systems, Inc.  All rights reserved.
# Copyright (c) 2012-2013 Los Alamos National Security, LLC.  All rights reserved.
# Copyright (c) 2015      Intel, Inc. All rights reserved.
# Copyright (c) 2015-2016 Research Organization for Information Science
#                         and Technology (RIST). All rights reserved.
#
# $COPYRIGHT$
#
# Additional copyrights may follow
#
# $HEADER$
#
AC_DEFUN([MCA_opal_event_libevent2022_PRIORITY], [80])

#
# Force this component to compile in static-only mode
#
AC_DEFUN([MCA_opal_event_libevent2022_COMPILE_MODE], [
    AC_MSG_CHECKING([for MCA component $2:$3 compile mode])
    $4="static"
    AC_MSG_RESULT([$$4])
])

AC_DEFUN([MCA_opal_event_libevent2022_POST_CONFIG], [
    AM_CONDITIONAL(OPAL_EVENT_HAVE_THREAD_SUPPORT, test "$enable_event_thread_support" = "yes")
    AS_IF([test "$1" = "1"],
          [ # Build libevent/include/event2/event-config.h.  If we
           # don't do it here, then libevent's Makefile.am will build
           # it during "make all", which is too late for us (because
           # other things are built before the event framework that
           # end up including event-config.h).  The steps below were
           # copied from libevent's Makefile.am.

           AC_CONFIG_COMMANDS([opal/mca/event/libevent2022/libevent/include/event2/event-config.h],
                              [libevent_basedir="opal/mca/event/libevent2022"
                               libevent_file="$libevent_basedir/libevent/include/event2/event-config.h"
                               rm -f "$libevent_file.new"
                               cat > "$libevent_file.new" <<EOF
/* event2/event-config.h
 *
 * This file was generated by autoconf when libevent was built, and
 * post- processed by Open MPI's component configure.m4 (so that
 * Libevent wouldn't build it during "make all") so that its macros
 * would have a uniform prefix.
 *
 * DO NOT EDIT THIS FILE.
 *
 * Do not rely on macros in this file existing in later versions
 */
#ifndef _EVENT2_EVENT_CONFIG_H_
#define _EVENT2_EVENT_CONFIG_H_
EOF

                               sed -e 's/#define /#define _EVENT_/' \
                                   -e 's/#undef /#undef _EVENT_/' \
                                   -e 's/#ifndef /#ifndef _EVENT_/' < "$libevent_basedir/libevent/config.h" >> "$libevent_file.new"
                               echo "#endif" >> "$libevent_file.new"

                               # Only make a new .h libevent_file if the
                               # contents haven't changed
                               diff -q $libevent_file "$libevent_file.new" > /dev/null 2> /dev/null
                               if test "$?" = "0"; then
                                   echo $libevent_file is unchanged
                               else
                                   cp "$libevent_file.new" $libevent_file
                               fi
                               rm -f "$libevent_file.new"])

           # Must set this variable so that the framework m4 knows
           # what file to include in opal/mca/event/event.h
           opal_event_base_include="libevent2022/libevent2022.h"

           # Add some stuff to CPPFLAGS so that the rest of the source
           # tree can be built
           libevent_file=$libevent_basedir/libevent
           CPPFLAGS="$CPPFLAGS -I$OPAL_TOP_SRCDIR/$libevent_file -I$OPAL_TOP_SRCDIR/$libevent_file/include"
           AS_IF([test "$OPAL_TOP_BUILDDIR" != "$OPAL_TOP_SRCDIR"],
                 [CPPFLAGS="$CPPFLAGS -I$OPAL_TOP_BUILDDIR/$libevent_file/include"])
           unset libevent_file
          ])
])

# MCA_event_libevent2022_CONFIG([action-if-can-compile],
#                              [action-if-cant-compile])
# ------------------------------------------------
AC_DEFUN([MCA_opal_event_libevent2022_CONFIG],[
    OPAL_VAR_SCOPE_PUSH([CFLAGS_save CPPFLAGS_save libevent_file event_args libevent_happy])

    AC_CONFIG_FILES([opal/mca/event/libevent2022/Makefile])
    libevent_basedir="opal/mca/event/libevent2022"

    CFLAGS_save="$CFLAGS"
    CFLAGS="$OPAL_CFLAGS_BEFORE_PICKY $OPAL_VISIBILITY_CFLAGS"
    CPPFLAGS_save="$CPPFLAGS"
    CPPFLAGS="-I$OPAL_TOP_SRCDIR -I$OPAL_TOP_BUILDDIR -I$OPAL_TOP_SRCDIR/opal/include $CPPFLAGS"

    AC_MSG_CHECKING([libevent configuration args])
    event_args="--disable-dns --disable-http --disable-rpc --disable-openssl --enable-thread-support"

    AC_ARG_ENABLE(event-rtsig,
        AC_HELP_STRING([--enable-event-rtsig],
                       [enable support for real time signals (experimental)]))
    if test "$enable_event_rtsig" = "yes"; then
        event_args="$event_args --enable-rtsig"
    fi

    AC_ARG_ENABLE(event-select,
                  AC_HELP_STRING([--disable-event-select], [disable select support]))
    if test "$enable_event_select" = "no"; then
        event_args="$event_args --disable-select"
    fi

    AC_ARG_ENABLE(event-poll,
                  AC_HELP_STRING([--disable-event-poll], [disable poll support]))
    if test "$enable_event_poll" = "no"; then
        event_args="$event_args --disable-poll"
    fi

    AC_ARG_ENABLE(event-devpoll,
                  AC_HELP_STRING([--disable-event-devpoll], [disable devpoll support]))
    if test "$enable_event_devpoll" = "no"; then
        event_args="$event_args --disable-devpoll"
    fi

    AC_ARG_ENABLE(event-kqueue,
                  AC_HELP_STRING([--disable-event-kqueue], [disable kqueue support]))
    if test "$enable_event_kqueue" = "no"; then
        event_args="$event_args --disable-kqueue"
    fi

    AC_ARG_ENABLE(event-epoll,
                  AC_HELP_STRING([--disable-event-epoll], [disable epoll support]))
    if test "$enable_event_epoll" = "no"; then
        event_args="$event_args --disable-epoll"
    fi

    AC_ARG_ENABLE(event-evport,
                  AC_HELP_STRING([--enable-event-evport], [enable evport support]))
    if test "$enable_event_evport" = "yes"; then
        event_args="$event_args --enable-evport"
    else
        event_args="$event_args --disable-evport"
    fi

    AC_ARG_ENABLE(event-signal,
                  AC_HELP_STRING([--disable-event-signal], [disable signal support]))
    if test "$enable_event_signal" = "no"; then
        event_args="$event_args --disable-signal"
    fi

    AC_ARG_ENABLE(event-debug,
                  AC_HELP_STRING([--enable-event-debug], [enable event library debug output]))
    if test "$enable_event_debug" = "yes"; then
        event_args="$event_args --enable-debug-mode"
    fi

    AC_MSG_RESULT([$event_args])

    OPAL_CONFIG_SUBDIR([$libevent_basedir/libevent],
        [$event_args $opal_subdir_args],
        [libevent_happy="yes"], [libevent_happy="no"])
    if test "$libevent_happy" = "no"; then
        AC_MSG_WARN([Event library failed to configure])
        AC_MSG_ERROR([Cannot continue])
    fi

    # Finally, add some flags to the wrapper compiler if we're
    # building with developer headers so that our headers can
    # be found.
    event_libevent2022_WRAPPER_EXTRA_CPPFLAGS='-I${pkgincludedir}/opal/mca/event/libevent2022/libevent -I${pkgincludedir}/opal/mca/event/libevent2022/libevent/include'

    CFLAGS="$CFLAGS_save"
    CPPFLAGS="$CPPFLAGS_save"

    # If we configured successfully, set OPAL_HAVE_WORKING_EVENTOPS to
    # the value in the generated libevent/config.h (NOT
    # libevent/include/event2/event-config.h!).  Otherwise, set it to
    # 0.
    libevent_file=$libevent_basedir/libevent/config.h

    # If we are not building the internal libevent, then indicate that
    # this component should not be built.  NOTE: we still did all the
    # above configury so that all the proper GNU Autotools
    # infrastructure is setup properly (e.g., w.r.t. SUBDIRS=libevent in
    # this directory's Makefile.am, we still need the Autotools "make
    # distclean" infrastructure to work properly).

    AS_IF([test "$with_libevent" != "internal" && test -n "$with_libevent" && test "$with_libevent" != "yes"],
          [AC_MSG_WARN([using an external libevent; disqualifying this component])
           libevent_happy=no],

          [AS_IF([test "$libevent_happy" = "yes" && test -r $libevent_file],
            [OPAL_HAVE_WORKING_EVENTOPS=`grep HAVE_WORKING_EVENTOPS $libevent_file | awk '{print [$]3 }'`
              $1],
            [$2
              OPAL_HAVE_WORKING_EVENTOPS=0])
          ]
    )

    OPAL_VAR_SCOPE_POP
])
