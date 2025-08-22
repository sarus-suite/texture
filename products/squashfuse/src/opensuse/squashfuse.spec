%define build_ver       %(echo "${SQUASHFUSE_VERSION}")
%define build_rel       %(echo "${SQUASHFUSE_RELEASE}")

Name:     squashfuse
Version:  %{build_ver}
Release:  %{build_rel}
Summary:  FUSE filesystem to mount squashfs archives

License:  BSD
URL:      https://github.com/vasi/squashfuse
Source0:  https://github.com/vasi/squashfuse/archive/%{version}/%{name}-%{version}.tar.gz

BuildRequires: make
BuildRequires: autoconf, automake, fuse-devel, gcc, libattr-devel, libtool, libzstd-devel, liblz4-devel, xz-devel, zlib-devel
Requires: %{name}-libs%{?_isa} = %{version}-%{release}

%description
Squashfuse lets you mount SquashFS archives in user-space. It supports almost
all features of the SquashFS format, yet is still fast and memory-efficient.
SquashFS is an efficiently compressed, read-only storage format. Support for it
has been built into the Linux kernel since 2009. It is very common on Live CDs
and embedded Linux distributions.


%package devel
Summary: Development files for %{name}
Requires: %{name}-libs%{?_isa} = %{version}-%{release}

%description devel
Libraries and header files for developing applications that use %{name}.


%package libs
Summary: Libraries for %{name}

%description libs
Libraries for running %{name} applications.


%prep
%autosetup -p1


%build
./autogen.sh
%configure --disable-static --disable-demo
%make_build

%install
%make_install
find %{buildroot} -name '*.la' -print -delete


%files
%license LICENSE
%{_bindir}/*
%{_mandir}/man1/*

%files devel
%{_includedir}/squashfuse/
%{_libdir}/pkgconfig/squashfuse.pc
%{_libdir}/pkgconfig/squashfuse_ll.pc
%{_libdir}/*.so

%files libs
%{_libdir}/*.so.*

%post -p /sbin/ldconfig
%postun -p /sbin/ldconfig

%changelog
