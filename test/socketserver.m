#import <Foundation/Foundation.h>
#import <sys/socket.h>
#import <sys/un.h>


static char *socket_dir = ".";
static char *socket_name = "test_socket";
static char socket_path[256];
static char *random_path = "/dev/urandom";
#define MAX_MSG_SIZE 65536


void cleanup(void) {
    if (socket_path[0] != '\0') {
        printf("Removing %s\n", socket_path);
        unlink(socket_path);
        memset(socket_path, 0, sizeof(socket_path));
    }
}

volatile sig_atomic_t fatal_error_in_progress = 0;

void signal_cleanup(int sig) {
    if (fatal_error_in_progress) {
        raise(sig);
    }
    fatal_error_in_progress = 1;
    
    cleanup();
    
    signal(sig, SIG_DFL);
    raise(sig);
}


int main (int argc, const char * argv[]) {
    char *path_ptr;
    size_t path_len;
    uint64_t rand_num;
    int fd;
    
    int sock, length;
    struct sockaddr_un sock_name;
    
    size_t len;
    unsigned char msg_buf[MAX_MSG_SIZE];
    char str_buf[MAX_MSG_SIZE + 1];
    
    // Read random bytes into buffer.
    if ((fd = open(random_path, O_RDONLY)) < 0) {
        perror("Couldn't read random data");
        return 1;
    }
    if (read(fd, &rand_num, sizeof(rand_num)) != sizeof(rand_num)) {
        perror("Couldn't read random data");
        return 1;
    }
    close(fd);
    
    // Ensure path buffer is filled by 0s.
    memset(socket_path, 0, sizeof(socket_path));
    // Generate random socket name.
    strlcpy(socket_path, socket_dir, sizeof(socket_path));
    strlcat(socket_path, "/", sizeof(socket_path));
    strlcat(socket_path, socket_name, sizeof(socket_path));
    strlcat(socket_path, ".", sizeof(socket_path));
    path_len = strlen(socket_path);
    path_ptr = &socket_path[path_len];
    snprintf(path_ptr, sizeof(socket_path) - path_len, "%016llx", rand_num);
    
    printf("Creating socket at %s\n", socket_path);
    
    // Create socket from which to read.
    sock = socket(AF_UNIX, SOCK_DGRAM, 0);
    if (sock < 0) {
        perror("Error opening datagram socket");
        return 1;
    }
    
    // Create socket name structure.
    sock_name.sun_family = AF_UNIX;
    strlcpy(sock_name.sun_path, socket_path, sizeof(sock_name.sun_path));
    sock_name.sun_len = SUN_LEN(&sock_name);
    
    // Bind to socket.
    if (bind(sock, (struct sockaddr *) &sock_name, sizeof(struct sockaddr_un)) != 0) {
        perror("Error binding to datagram socket");
        return 1;
    }
    
    // Set cleanup() to be called on program termination.
    atexit(cleanup);
    signal(SIGHUP,  signal_cleanup);
    signal(SIGINT,  signal_cleanup);
    signal(SIGTERM, signal_cleanup);
    signal(SIGABRT, signal_cleanup);
    signal(SIGPIPE, signal_cleanup);
    
    @autoreleasepool {
        for (;;) {
            len = recv(sock, msg_buf, sizeof(msg_buf), MSG_WAITALL);
            memcpy(str_buf, msg_buf, len);
            str_buf[len] = '\0';
            printf("Received: %s\n", str_buf);
        }
    }
    return 0;
}
