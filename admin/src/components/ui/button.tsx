import type { ButtonHTMLAttributes, ReactNode } from "react";

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
	variant?: "primary" | "ghost";
	children: ReactNode;
}

export function Button({
	variant = "primary",
	children,
	className = "",
	...props
}: ButtonProps) {
	const base =
		"inline-flex items-center justify-center rounded-lg px-4 py-2 text-sm font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-cyan/50 disabled:opacity-50 disabled:cursor-not-allowed";
	const variants = {
		primary: "bg-cyan text-navy hover:bg-cyan/90",
		ghost: "bg-transparent text-gray-300 hover:bg-navy-lighter hover:text-white",
	};

	return (
		<button
			className={`${base} ${variants[variant]} ${className}`}
			{...props}
		>
			{children}
		</button>
	);
}
