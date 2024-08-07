#include <signal.h>

int
main()
{
	sigset_t sigs;

	sigemptyset(&sigs);
	sigaddset(&sigs, SIGINT);
	sigaddset(&sigs, SIGTERM);
	sigaddset(&sigs, SIGHUP);

	sigprocmask(SIG_BLOCK, &sigs, 0);

	while (sigwaitinfo(&sigs, 0) == SIGHUP)
		;

	return 0;
}
