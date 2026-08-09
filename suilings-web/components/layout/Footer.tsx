import Link from "next/link";

export function Footer() {
  return (
    <footer className="border-t border-border mt-20">
      <div className="container mx-auto px-4 py-8">
        <div className="flex flex-col md:flex-row items-center justify-between gap-4">
          <div className="text-sm text-muted-foreground">
            <p>
              © 2025 All Rights Reserved @{" "}
              <a
                href="https://github.com/ankiitagrwal"
                target="_blank"
                rel="noopener noreferrer"
                className="text-indigo-600 hover:underline"
              >
                Ankit Agrawal
              </a>
            </p>
            <p className="mt-1 text-xs">
              All exercises based on{" "}
              <a 
                href="https://move-book.com" 
                target="_blank" 
                rel="noopener noreferrer" 
                className="text-indigo-600 hover:underline"
              >
                Move Book
              </a>
            </p>
          </div>
          <div className="flex items-center gap-6">
            <Link 
              href="https://docs.sui.io" 
              target="_blank" 
              rel="noopener noreferrer" 
              className="text-sm text-muted-foreground hover:text-foreground transition-colors"
            >
              Sui Docs
            </Link>
            <Link 
              href="https://github.com/MystenLabs/sui" 
              target="_blank" 
              rel="noopener noreferrer" 
              className="text-sm text-muted-foreground hover:text-foreground transition-colors"
            >
              Sui GitHub
            </Link>
            <Link 
              href="/feedback" 
              className="text-sm text-muted-foreground hover:text-foreground transition-colors"
            >
              Feedback
            </Link>
            <Link 
              href="/exercise" 
              className="text-sm text-muted-foreground hover:text-foreground transition-colors"
            >
              Start Learning
            </Link>
          </div>
        </div>
      </div>
    </footer>
  );
}

