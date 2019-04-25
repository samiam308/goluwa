-- FreeBSD error messages

local require = require

local version = require "syscall.freebsd.version".version

local errors = {
  PERM = "Operation not permitted",
  NOENT = "No such file or directory",
  SRCH = "No such process",
  INTR = "Interrupted system call",
  IO = "Input/output error",
  NXIO = "Device not configured",
  ["2BIG"] = "Argument list too long",
  NOEXEC = "Exec format error",
  BADF = "Bad file descriptor",
  CHILD = "No child processes",
  DEADLK = "Resource deadlock avoided",
  NOMEM = "Cannot allocate memory",
  ACCES = "Permission denied",
  FAULT = "Bad address",
  NOTBLK = "Block device required",
  BUSY = "Resource busy",
  EXIST = "File exists",
  XDEV = "Cross-device link",
  NODEV = "Operation not supported by device",
  NOTDIR = "Not a directory",
  ISDIR = "Is a directory",
  INVAL = "Invalid argument",
  NFILE = "Too many open files in system",
  MFILE = "Too many open files",
  NOTTY = "Inappropriate ioctl for device",
  TXTBSY = "Text file busy",
  FBIG = "File too large",
  NOSPC = "No space left on device",
  SPIPE = "Illegal seek",
  ROFS = "Read-only file system",
  MLINK = "Too many links",
  PIPE = "Broken pipe",
  DOM = "Numerical argument out of domain",
  RANGE = "Result too large",
  AGAIN = "Resource temporarily unavailable",
  INPROGRESS = "Operation now in progress",
  ALREADY = "Operation already in progress",
  NOTSOCK = "Socket operation on non-socket",
  DESTADDRREQ = "Destination address required",
  MSGSIZE = "Message too long",
  PROTOTYPE = "Protocol wrong type for socket",
  NOPROTOOPT = "Protocol not available",
  PROTONOSUPPORT = "Protocol not supported",
  SOCKTNOSUPPORT = "Socket type not supported",
  OPNOTSUPP = "Operation not supported",
  PFNOSUPPORT = "Protocol family not supported",
  AFNOSUPPORT = "Address family not supported by protocol family",
  ADDRINUSE = "Address already in use",
  ADDRNOTAVAIL = "Can't assign requested address",
  NETDOWN = "Network is down",
  NETUNREACH = "Network is unreachable",
  NETRESET = "Network dropped connection on reset",
  CONNABORTED = "Software caused connection abort",
  CONNRESET = "Connection reset by peer",
  NOBUFS = "No buffer space available",
  ISCONN = "Socket is already connected",
  NOTCONN = "Socket is not connected",
  SHUTDOWN = "Can't send after socket shutdown",
  TOOMANYREFS = "Too many references: can't splice",
  TIMEDOUT = "Operation timed out",
  CONNREFUSED = "Connection refused",
  LOOP = "Too many levels of symbolic links",
  NAMETOOLONG = "File name too long",
  HOSTDOWN = "Host is down",
  HOSTUNREACH = "No route to host",
  NOTEMPTY = "Directory not empty",
  PROCLIM = "Too many processes",
  USERS = "Too many users",
  DQUOT = "Disc quota exceeded",
  STALE = "Stale NFS file handle",
  REMOTE = "Too many levels of remote in path",
  BADRPC = "RPC struct is bad",
  RPCMISMATCH = "RPC version wrong",
  PROGUNAVAIL = "RPC prog. not avail",
  PROGMISMATCH = "Program version wrong",
  PROCUNAVAIL = "Bad procedure for program",
  NOLCK = "No locks available",
  NOSYS = "Function not implemented",
  FTYPE = "Inappropriate file type or format",
  AUTH = "Authentication error",
  NEEDAUTH = "Need authenticator",
  IDRM = "Identifier removed",
  NOMSG = "No message of desired type",
  OVERFLOW = "Value too large to be stored in data type",
  CANCELED = "Operation canceled",
  ILSEQ = "Illegal byte sequence",
  NOATTR = "Attribute not found",
  DOOFUS = "Programming error",
  BADMSG = "Bad message",
  MULTIHOP = "Multihop attempted",
  NOLINK = "Link has been severed",
  PROTO = "Protocol error",
  NOTCAPABLE = "Capabilities insufficient",
  CAPMODE = "Not permitted in capability mode",
}

if version >= 10 then
  errors.NOTRECOVERABLE = "State not recoverable"
  errors.OWNERDEAD = "Previous owner died"
end

return errors

